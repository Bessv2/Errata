class_name AimAssist
extends RefCounted
## Aim assist maths (pure functions; PlayerInput calls them).
## Picks the monster the player most likely means, keeps it as a soft lock so the
## aim doesn't flicker between neighbours, and bends the aim toward it.
## Distances and angles are measured on the isometric ground.


## The monster to lock onto, or null if none qualifies.
## [param current] is the monster locked last frame; it gets a bonus (lock_stickiness).
static func pick_target(origin: Vector2, raw_aim: Vector2, candidates: Array[Node],
		profile: AimAssistProfile, current: Node2D) -> Node2D:
	if not profile.enabled or raw_aim == Vector2.ZERO:
		return null
	var aim_ground: Vector2 = Iso.to_ground(raw_aim).normalized()
	var half_cone: float = deg_to_rad(profile.cone_degrees) / 2.0
	var best: Node2D = null
	var best_score: float = INF
	for node in candidates:
		var target: Node2D = node as Node2D
		var offset: Vector2 = Iso.to_ground(target.global_position - origin)
		var distance: float = offset.length()
		if distance > profile.radius:
			continue
		var angle: float = 0.0 if distance < 0.001 else absf(aim_ground.angle_to(offset))
		if angle > half_cone:
			continue
		# Lower is better: a blend of "how far off the aim" and "how far away".
		var score: float = (1.0 - profile.distance_weight) * (angle / maxf(half_cone, 0.001)) \
				+ profile.distance_weight * (distance / profile.radius)
		if target == current:
			score *= 1.0 - profile.lock_stickiness
		if score < best_score:
			best = target
			best_score = score
	return best


## The raw aim bent toward [param target] by the profile's snap strength (unit vector).
static func bend_toward(origin: Vector2, raw_aim: Vector2, target: Node2D,
		profile: AimAssistProfile) -> Vector2:
	if target == null:
		return raw_aim.normalized()
	var to_target: Vector2 = target.global_position - origin
	if to_target.length() < 0.001:
		return raw_aim.normalized()
	return raw_aim.normalized().slerp(to_target.normalized(), profile.snap_strength).normalized()
