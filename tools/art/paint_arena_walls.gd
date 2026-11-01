extends SceneTree
## Builds the arena's back walls from the approved PixelLab wall block.
## Adds the block to the arena tileset, removes the old Kenney placeholder tiles
## from it, and redraws every cell of the arena's Walls layer with the block.
## Run after changing the wall art or the arena's shape:
##   godot --headless --path . --script res://tools/art/paint_arena_walls.gd
## Only the Walls layer's tile data and tint are touched in arena.tscn; the rest
## of the scene is left as written (its scripts need the game's autoloads).

const TILESET_PATH: String = "res://scenes/world/arena_tiles.tres"
const ARENA_PATH: String = "res://scenes/world/arena.tscn"

## Tileset source id and texture of the wall block.
const WALL_ID: int = 52
const WALL_TEXTURE: String = "res://assets/art/world/walls/ruin_wall.png"
## How far below the image centre the block's base sits (PixelLab 64px "block" tiles).
const BASE_OFFSET: int = 16


func _init() -> void:
	# --- Tileset: drop placeholder sources, add the wall block ---
	var tileset: TileSet = load(TILESET_PATH)
	for i in range(tileset.get_source_count() - 1, -1, -1):
		var id: int = tileset.get_source_id(i)
		var source: TileSetAtlasSource = tileset.get_source(id) as TileSetAtlasSource
		if id == WALL_ID or (source and source.texture.resource_path.contains("/placeholder/")):
			tileset.remove_source(id)
	var wall: TileSetAtlasSource = TileSetAtlasSource.new()
	wall.resource_name = WALL_TEXTURE.get_file().get_basename()
	wall.texture = load(WALL_TEXTURE)
	wall.texture_region_size = Vector2i(64, 64)
	wall.create_tile(Vector2i.ZERO)
	wall.get_tile_data(Vector2i.ZERO, 0).texture_origin = Vector2i(0, BASE_OFFSET)
	tileset.add_source(wall, WALL_ID)
	print("Tileset: %s" % error_string(ResourceSaver.save(tileset, TILESET_PATH)))

	# --- Arena: rewrite only the Walls node's tile data, drop its tint ---
	var lines: PackedStringArray = FileAccess.get_file_as_string(ARENA_PATH).split("\n")
	var out: PackedStringArray = PackedStringArray()
	var in_walls: bool = false
	for line in lines:
		if line.begins_with("["):
			in_walls = line.begins_with("[node name=\"Walls\"")
		elif in_walls and line.begins_with("modulate = "):
			continue   # real art is drawn in palette, no tint
		elif in_walls and line.begins_with("tile_map_data = "):
			line = "tile_map_data = " + var_to_str(_repaint(str_to_var(line.trim_prefix("tile_map_data = "))))
		out.append(line)
	var file: FileAccess = FileAccess.open(ARENA_PATH, FileAccess.WRITE)
	file.store_string("\n".join(out))
	file.close()
	print("Arena walls repainted")
	quit()


# Same cells as before, every one drawn with the wall block.
func _repaint(data: PackedByteArray) -> PackedByteArray:
	var layer: TileMapLayer = TileMapLayer.new()
	layer.tile_map_data = data
	var cells: Array[Vector2i] = layer.get_used_cells()
	layer.clear()
	for cell in cells:
		layer.set_cell(cell, WALL_ID, Vector2i.ZERO)
	var result: PackedByteArray = layer.tile_map_data
	layer.free()
	return result
