extends Node
## Aim assist: target choice, soft lock and snapping, per device profile.

const CFG: AimAssistConfig = preload("res://data/input/aim_assist.tres")


func _mite(at: Vector2) -> Node2D:
	var n: Node2D = Node2D.new()
	n.position = at
	add_child(n)
	return n


func run(t: Node) -> void:
	var front: Node2D = _mite(Vector2(40, 5))
	var side: Node2D = _mite(Vector2(0, -25))
	var far: Node2D = _mite(Vector2(120, 0))
	var behind: Node2D = _mite(Vector2(-30, 0))
	var all: Array[Node] = [front, side, far, behind]
	t.check("controller locks the mite in front",
			AimAssist.pick_target(Vector2.ZERO, Vector2.RIGHT, all, CFG.gamepad, null) == front)
	t.check("controller ignores mites 90 deg off or out of range",
			AimAssist.pick_target(Vector2.ZERO, Vector2.RIGHT, [side, far] as Array[Node], CFG.gamepad, null) == null)
	t.check("mouse has no assist",
			AimAssist.pick_target(Vector2.ZERO, Vector2.RIGHT, all, CFG.keyboard_mouse, null) == null)
	t.check("touch's wide cone finds a mite off to the side",
			AimAssist.pick_target(Vector2.ZERO, Vector2.RIGHT, [side, behind] as Array[Node], CFG.touch, null) == side)

	var a: Node2D = _mite(Vector2(40, 4))
	var b: Node2D = _mite(Vector2(38, -4))
	var pair: Array[Node] = [a, b]
	var first: Node2D = AimAssist.pick_target(Vector2.ZERO, Vector2.RIGHT, pair, CFG.gamepad, null)
	t.check("lock holds when a neighbour is only slightly better",
			AimAssist.pick_target(Vector2.ZERO, Vector2(1, 0.05).normalized(), pair, CFG.gamepad, first) == first)

	var bent: Vector2 = AimAssist.bend_toward(Vector2.ZERO, Vector2.RIGHT, side, CFG.gamepad)
	var expected: float = -90.0 * CFG.gamepad.snap_strength
	t.check("aim bends %d%% of the way to the target" % roundi(CFG.gamepad.snap_strength * 100),
			absf(rad_to_deg(Vector2.RIGHT.angle_to(bent)) - expected) < 1.0)
