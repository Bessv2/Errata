class_name EnemySpawner
extends Node
## Keeps the arena stocked: spawns one group of monsters, and when the whole group
## is dead, waits and spawns the next. Group size comes from the monster's data;
## timing and placement come from data/world/arena_spawns.tres.

## The monster scene to spawn (e.g. void_mite.tscn).
@export var monster_scene: PackedScene
## The same monster's data, read for group size.
@export var monster_data: MonsterData
## Spawn timing and placement.
@export var config: SpawnConfig
## The floor tiles; groups only appear on floor cells.
@export var floor_layer: TileMapLayer
## Where spawned monsters are added (the y-sorted Entities node).
@export var container: Node2D

var _alive: int = 0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _caps: PlatformCaps = PlatformCaps.current()


func _ready() -> void:
	_rng.randomize()
	# Wait one frame so the hero is in place before the first group appears.
	_spawn_group.call_deferred()


# --- Spawning ----------------------------------------------------------------

func _spawn_group() -> void:
	var hero: Node2D = get_tree().get_first_node_in_group("hero")
	var centre: Vector2 = _pick_group_centre(hero)
	var count: int = _rng.randi_range(monster_data.group_size_min, monster_data.group_size_max)
	# Never exceed this platform's monster cap (data/platform/caps_*.tres).
	count = mini(count, _caps.max_enemies_alive - _alive)
	for i in count:
		var monster: Node2D = monster_scene.instantiate()
		var offset: Vector2 = Vector2.from_angle(_rng.randf() * TAU) * _rng.randf() * config.group_radius
		monster.position = centre + offset
		monster.set("target", hero)
		monster.tree_exited.connect(_on_monster_gone)
		container.add_child(monster)
		_alive += 1


# Picks a random floor cell away from the edges and far enough from the hero.
func _pick_group_centre(hero: Node2D) -> Vector2:
	var cells: Array[Vector2i] = _spawnable_cells()
	var best: Vector2 = floor_layer.map_to_local(cells[0])
	var best_distance: float = -1.0
	for attempt in 30:
		var pos: Vector2 = floor_layer.map_to_local(cells[_rng.randi_range(0, cells.size() - 1)])
		var distance: float = INF if hero == null else pos.distance_to(hero.position)
		if distance >= config.min_distance_from_hero:
			return pos
		if distance > best_distance:
			best = pos
			best_distance = distance
	return best


# Floor cells at least edge_margin_cells away from the arena's outer edge.
func _spawnable_cells() -> Array[Vector2i]:
	var bounds: Rect2i = floor_layer.get_used_rect()
	var m: int = config.edge_margin_cells
	var result: Array[Vector2i] = []
	for cell in floor_layer.get_used_cells():
		if cell.x >= bounds.position.x + m and cell.x < bounds.end.x - m \
				and cell.y >= bounds.position.y + m and cell.y < bounds.end.y - m:
			result.append(cell)
	return result


# --- Respawn -----------------------------------------------------------------

func _on_monster_gone() -> void:
	_alive -= 1
	if _alive == 0 and is_inside_tree():
		await get_tree().create_timer(config.respawn_delay).timeout
		_spawn_group()
