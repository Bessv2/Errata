extends SceneTree
## Paints the arena floor with the approved PixelLab ground tiles.
## Adds the tiles to the arena tileset (if missing), then repaints every cell of
## the arena's Floor layer: mostly softened flagstone, with patches of ash.
## Run after changing the floor art or the arena's shape:
##   godot --headless --path . --script res://tools/art/paint_arena_floor.gd
## Only the Floor layer's tile data and tint are touched in arena.tscn; the rest
## of the scene is left as written (its scripts need the game's autoloads).

const TILESET_PATH: String = "res://scenes/world/arena_tiles.tres"
const ARENA_PATH: String = "res://scenes/world/arena.tscn"

## Tileset source id -> texture. Ids 50+ are the approved ground tiles.
const GROUND_TILES: Dictionary = {
	50: "res://assets/art/world/ground/flagstone_soft.png",
	51: "res://assets/art/world/ground/ash.png",
}
## How far below the image centre the tile's top face sits (PixelLab 64px thin tiles).
const TOP_FACE_OFFSET: int = 6
## Share of floor cells painted with ash instead of flagstone.
const ASH_SHARE: float = 0.1
## Fixed seed so the floor looks the same every time the tool runs.
const SEED: int = 1027


func _init() -> void:
	# --- Tileset: add the ground tiles as their own sources ---
	var tileset: TileSet = load(TILESET_PATH)
	for id: int in GROUND_TILES:
		if tileset.has_source(id):
			tileset.remove_source(id)
		var source: TileSetAtlasSource = TileSetAtlasSource.new()
		source.resource_name = GROUND_TILES[id].get_file().get_basename()
		source.texture = load(GROUND_TILES[id])
		source.texture_region_size = Vector2i(64, 64)
		source.create_tile(Vector2i.ZERO)
		source.get_tile_data(Vector2i.ZERO, 0).texture_origin = Vector2i(0, TOP_FACE_OFFSET)
		tileset.add_source(source, id)
	print("Tileset: %s" % error_string(ResourceSaver.save(tileset, TILESET_PATH)))

	# --- Arena: find the Floor node's lines in the scene file ---
	var lines: PackedStringArray = FileAccess.get_file_as_string(ARENA_PATH).split("\n")
	var start: int = -1
	for i in lines.size():
		if lines[i].begins_with("[node name=\"Floor\""):
			start = i
	if start < 0:
		push_error("No Floor node in " + ARENA_PATH)
		quit(1)
		return
	var out: PackedStringArray = PackedStringArray()
	var in_floor: bool = false
	for i in lines.size():
		var line: String = lines[i]
		if line.begins_with("["):
			in_floor = (i == start)
		elif in_floor and line.begins_with("modulate = "):
			continue   # real art is drawn in palette, no tint
		elif in_floor and line.begins_with("tile_map_data = "):
			line = "tile_map_data = " + var_to_str(_repaint(str_to_var(line.trim_prefix("tile_map_data = "))))
		out.append(line)
	var file: FileAccess = FileAccess.open(ARENA_PATH, FileAccess.WRITE)
	file.store_string("\n".join(out))
	file.close()
	print("Arena floor repainted")
	quit()


# Same cells as before, each set to flagstone or (sometimes) ash.
func _repaint(data: PackedByteArray) -> PackedByteArray:
	var layer: TileMapLayer = TileMapLayer.new()
	layer.tile_map_data = data
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = SEED
	var cells: Array[Vector2i] = layer.get_used_cells()
	cells.sort()   # stable order, so the seed always gives the same floor
	for cell in cells:
		layer.set_cell(cell, 51 if rng.randf() < ASH_SHARE else 50, Vector2i.ZERO)
	var result: PackedByteArray = layer.tile_map_data
	layer.free()
	return result
