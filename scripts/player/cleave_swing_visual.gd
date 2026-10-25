extends Node2D
## Basic swing visual for Cleave: a pale crescent on the floor that fades fast.
## Placeholder until the feel pass (step 6) adds particles, hit-stop and shake.

## Seconds the crescent stays visible.
const LIFETIME: float = 0.12
const COLOR: Color = Color(0.85, 0.82, 0.72)

@export var cleave: Cleave

var _direction: Vector2 = Vector2.RIGHT
var _age: float = LIFETIME  # starts finished, so nothing shows until the first swing


func _ready() -> void:
	cleave.swung.connect(_on_swung)


func _on_swung(direction: Vector2, _hits: Array[Node2D]) -> void:
	_direction = direction
	_age = 0.0
	queue_redraw()


func _process(delta: float) -> void:
	if _age < LIFETIME:
		_age += delta
		queue_redraw()


# Draws the arc's outline on the ground, matching what Cleave actually hits.
func _draw() -> void:
	if _age >= LIFETIME:
		return
	var color: Color = COLOR
	color.a = 1.0 - _age / LIFETIME
	var reach: float = cleave.data.reach
	var half_arc: float = deg_to_rad(cleave.data.arc_degrees) / 2.0
	var aim_angle: float = Iso.to_ground(_direction).angle()
	var outer: PackedVector2Array = PackedVector2Array()
	var steps: int = 12
	for i in steps + 1:
		var a: float = aim_angle - half_arc + 2.0 * half_arc * float(i) / float(steps)
		# Back from ground to screen: halve the height.
		outer.append(Vector2(cos(a) * reach, sin(a) * reach * 0.5))
	draw_polyline(outer, color, 2.0)
	var inner: PackedVector2Array = PackedVector2Array()
	for p in outer:
		inner.append(p * 0.7)
	draw_polyline(inner, Color(color, color.a * 0.5), 1.0)
