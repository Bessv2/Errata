extends Node2D
## Draws a small chevron at the hero's feet pointing where they aim, and a faint
## bracket under the monster aim assist is locked onto (if any).
## The hero rotates this node and sets locked_target; it only draws.

@export var distance: float = 18.0
@export var size: float = 4.0
@export var color: Color = Color(0.85, 0.82, 0.72, 0.8)
## Ground radius of the lock bracket under a target (pixels).
@export var lock_radius: float = 11.0

## The monster to mark, or null. Set by the hero each frame.
var locked_target: Node2D = null:
	set(value):
		locked_target = value
		queue_redraw()


func _process(_delta: float) -> void:
	if locked_target != null:
		queue_redraw()  # the target moves


func _draw() -> void:
	# Aim chevron (this node is rotated to the aim, so "forward" is +x).
	var tip: Vector2 = Vector2(distance + size, 0)
	var back_top: Vector2 = Vector2(distance, -size)
	var back_bottom: Vector2 = Vector2(distance, size)
	draw_polyline(PackedVector2Array([back_top, tip, back_bottom]), color, 1.0)
	if locked_target != null and is_instance_valid(locked_target):
		_draw_lock_bracket()


# Four short arcs of a flat ellipse under the target, drawn unrotated.
func _draw_lock_bracket() -> void:
	draw_set_transform(to_local(locked_target.global_position), -global_rotation)
	var faint: Color = Color(color, 0.75)
	for quarter in 4:
		var points: PackedVector2Array = PackedVector2Array()
		var start: float = TAU * quarter / 4.0 + 0.35
		for i in 4:
			var a: float = start + 0.25 * i
			points.append(Iso.to_screen(Vector2(cos(a), sin(a)) * lock_radius))
		draw_polyline(points, faint, 1.0)
	draw_set_transform(Vector2.ZERO, 0.0)
