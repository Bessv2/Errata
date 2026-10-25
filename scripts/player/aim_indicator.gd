extends Node2D
## Draws a small chevron at the hero's feet pointing where they aim.
## The hero rotates this node; it only draws.

@export var distance: float = 18.0
@export var size: float = 4.0
@export var color: Color = Color(0.85, 0.82, 0.72, 0.8)


func _draw() -> void:
	var tip: Vector2 = Vector2(distance + size, 0)
	var back_top: Vector2 = Vector2(distance, -size)
	var back_bottom: Vector2 = Vector2(distance, size)
	draw_polyline(PackedVector2Array([back_top, tip, back_bottom]), color, 1.0)
