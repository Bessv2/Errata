class_name RespawnService
extends Node
## Handles the hero's death and respawn (game state only; the death screen is UI).
## When the hero dies it announces, after a delay, that the death screen should show.
## When asked to "respawn nearby" it finds the closest safe floor spot and revives the hero.

## Fired when the death screen should appear.
signal death_screen_requested

## Delay and safety distance (data/world/respawn.tres).
@export var config: RespawnConfig
## The floor tiles; respawn spots are always on floor cells.
@export var floor_layer: TileMapLayer

var _hero: Hero
var _death_position: Vector2


func _ready() -> void:
	CombatEvents.character_died.connect(_on_character_died)


func _on_character_died(who: Node2D) -> void:
	if not who.is_in_group("hero"):
		return
	_hero = who
	_death_position = who.global_position
	await get_tree().create_timer(config.death_screen_delay).timeout
	death_screen_requested.emit()


## Revives the hero at the closest floor spot far enough from every monster.
func respawn_nearby() -> void:
	if _hero == null:
		return
	_hero.revive(find_safe_spot(_death_position))


## The floor-cell centre closest to [param near] that is at least
## config.min_enemy_distance from every monster. If none is safe enough,
## the spot farthest from the nearest monster.
func find_safe_spot(near: Vector2) -> Vector2:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	var best_safe: Vector2 = near
	var best_safe_distance: float = INF
	var fallback: Vector2 = near
	var fallback_clearance: float = -1.0
	for cell in _usable_cells():
		var spot: Vector2 = floor_layer.to_global(floor_layer.map_to_local(cell))
		var clearance: float = INF
		for enemy in enemies:
			clearance = minf(clearance, spot.distance_to((enemy as Node2D).global_position))
		if clearance >= config.min_enemy_distance:
			var distance: float = spot.distance_to(near)
			if distance < best_safe_distance:
				best_safe = spot
				best_safe_distance = distance
		elif clearance > fallback_clearance:
			fallback = spot
			fallback_clearance = clearance
	return best_safe if best_safe_distance < INF else fallback


# Floor cells at least edge_margin_cells away from the arena's outer edge.
func _usable_cells() -> Array[Vector2i]:
	var bounds: Rect2i = floor_layer.get_used_rect()
	var m: int = config.edge_margin_cells
	var result: Array[Vector2i] = []
	for cell in floor_layer.get_used_cells():
		if cell.x >= bounds.position.x + m and cell.x < bounds.end.x - m \
				and cell.y >= bounds.position.y + m and cell.y < bounds.end.y - m:
			result.append(cell)
	return result
