class_name Cleave
extends Node2D
## Cleave: a wide arc in front of the hero that hits every monster inside it.
## The hero calls try_use() while the button is held; the cooldown spaces the swings.
## Numbers come from data/skills/cleave.tres.

## Fired on every swing with the monsters it hit (may be empty). The swing visual listens.
signal swung(direction: Vector2, hits: Array[Node2D])

@export var data: SkillData

var _cooldown_left: float = 0.0


func _physics_process(delta: float) -> void:
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)


## Swings toward [param direction] if the cooldown allows. Returns true if it swung.
func try_use(direction: Vector2) -> bool:
	if _cooldown_left > 0.0:
		return false
	_cooldown_left = data.cooldown
	var user: Node2D = get_parent()
	var hits: Array[Node2D] = targets_in_arc(global_position, direction, get_tree().get_nodes_in_group("enemies"),
			data.reach, data.arc_degrees)
	for target in hits:
		var to_target: Vector2 = (target.global_position - global_position).normalized()
		(target.get_node("Health") as Health).take_damage(data.damage, user)
		if target.has_method("apply_knockback"):
			target.apply_knockback(to_target * data.knockback)
		CombatEvents.hit_landed.emit(user, target, data.damage, to_target)
	CombatEvents.skill_used.emit(user, &"cleave", direction)
	swung.emit(direction, hits)
	return true


## Which of [param candidates] are inside the arc. Measured on the isometric ground,
## where screen height counts double, so the arc covers a true half-circle of floor.
static func targets_in_arc(origin: Vector2, direction: Vector2, candidates: Array[Node],
		reach: float, arc_degrees: float) -> Array[Node2D]:
	var aim_ground: Vector2 = Iso.to_ground(direction).normalized()
	var half_arc: float = deg_to_rad(arc_degrees) / 2.0
	var result: Array[Node2D] = []
	for node in candidates:
		var target: Node2D = node as Node2D
		var offset: Vector2 = Iso.to_ground(target.global_position - origin)
		if offset.length() > reach:
			continue
		# Something standing right on top of the hero always counts.
		if offset.length() < 0.001 or absf(aim_ground.angle_to(offset)) <= half_arc:
			result.append(target)
	return result
