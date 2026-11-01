extends Node2D
## Draws a Void Mite: the approved style-test sprite (Void Mite #2, small) over a
## faint violet glow. The sprite flips to face left or right.
## During a bite wind-up it swells and the glow brightens, so the bite can be seen coming.
## Drawn in _draw (not a child Sprite2D) so the hit-flash material on this node applies to it.

const TEXTURE: Texture2D = preload("res://assets/art/enemies/void_mite.png")
## Where the sprite's feet sit, in pixels from its top-left corner.
const FEET: Vector2 = Vector2(14, 24)
const GLOW: Color = Color(0.55, 0.3, 0.85)
const GLOW_WINDUP: Color = Color(0.85, 0.6, 1.0)
## How much bigger the mite gets at the end of a wind-up (0.25 = 25%).
const WINDUP_SWELL: float = 0.25

## Which way the head points (unit vector). Set by the mite.
var facing: Vector2 = Vector2.RIGHT:
	set(value):
		var was_left: bool = facing.x < 0.0
		facing = value
		if (facing.x < 0.0) != was_left:
			queue_redraw()

## Wind-up progress, 0 = not biting, 1 = about to bite. Set by the mite.
var windup: float = 0.0:
	set(value):
		windup = value
		queue_redraw()


func _draw() -> void:
	var swell: float = 1.0 + WINDUP_SWELL * windup
	# Glow on the ground under the body, stronger as the bite gets close.
	var glow: Color = GLOW.lerp(GLOW_WINDUP, windup)
	glow.a = 0.2 + 0.55 * windup
	_draw_ellipse(Vector2(0, 0), Vector2(10, 4) * swell, glow)
	# The sprite, flipped to face its target and scaled from the feet.
	var flip: float = -1.0 if facing.x < 0.0 else 1.0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(flip * swell, swell))
	draw_texture(TEXTURE, -FEET)
	draw_set_transform(Vector2.ZERO)


# Draws a filled ellipse, squashed for the isometric ground plane.
func _draw_ellipse(centre: Vector2, radii: Vector2, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for i in 16:
		var a: float = TAU * float(i) / 16.0
		points.append(centre + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(points, color)
