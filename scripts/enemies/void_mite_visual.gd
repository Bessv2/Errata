extends Node2D
## Placeholder drawing of a Void Mite (until style-test art exists):
## a small dark tick with legs and a faint violet glow.
## During a bite wind-up it swells and the glow brightens, so the bite can be seen coming.

const CARAPACE: Color = Color(0.1, 0.08, 0.13)
const LEG: Color = Color(0.16, 0.13, 0.2)
const GLOW: Color = Color(0.55, 0.3, 0.85)
const GLOW_WINDUP: Color = Color(0.85, 0.6, 1.0)

## Which way the head points (unit vector). Set by the mite.
var facing: Vector2 = Vector2.RIGHT:
	set(value):
		facing = value
		queue_redraw()

## Wind-up progress, 0 = not biting, 1 = about to bite. Set by the mite.
var windup: float = 0.0:
	set(value):
		windup = value
		queue_redraw()


func _draw() -> void:
	var swell: float = 1.0 + 0.35 * windup
	var glow: Color = GLOW.lerp(GLOW_WINDUP, windup)
	glow.a = 0.25 + 0.55 * windup
	# Directions flattened onto the isometric ground (half height).
	var fwd: Vector2 = Vector2(facing.x, facing.y * 0.5)
	var side: Vector2 = Vector2(-facing.y, facing.x * 0.5)
	# Glow under the body.
	_draw_ellipse(Vector2(0, -2), Vector2(9, 5) * swell, glow)
	# Three legs per side, splayed outward and slightly back.
	for i in 3:
		var along: float = (float(i) - 1.0) * 2.5
		var root: Vector2 = Vector2(0, -3) + fwd * along
		var reach: Vector2 = fwd * (along * 0.8 - 1.0)
		draw_line(root + side * 3.0, root + side * 8.0 + reach + Vector2(0, 1), LEG, 1.0)
		draw_line(root - side * 3.0, root - side * 8.0 + reach + Vector2(0, 1), LEG, 1.0)
	# Body and head.
	_draw_ellipse(Vector2(0, -4), Vector2(5, 3.5) * swell, CARAPACE)
	var head: Vector2 = Vector2(0, -4) + fwd * 5.0 * swell
	draw_circle(head, 2.0 * swell, CARAPACE)
	# Glowing eye spot.
	draw_circle(head + fwd * 1.0 + Vector2(0, -0.5), 0.8, glow.lightened(0.4))


# Draws a filled ellipse, squashed for the isometric ground plane.
func _draw_ellipse(centre: Vector2, radii: Vector2, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for i in 16:
		var a: float = TAU * float(i) / 16.0
		points.append(centre + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(points, color)
