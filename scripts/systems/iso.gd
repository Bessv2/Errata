class_name Iso
extends RefCounted
## Isometric helpers. The floor is drawn at half height (2:1 tiles), so a step
## "up" the screen covers twice as much ground as the same step sideways.


## Converts a screen offset to a ground offset (true distances and angles on the floor).
static func to_ground(screen_offset: Vector2) -> Vector2:
	return Vector2(screen_offset.x, screen_offset.y * 2.0)


## Converts a ground offset back to a screen offset.
static func to_screen(ground_offset: Vector2) -> Vector2:
	return Vector2(ground_offset.x, ground_offset.y * 0.5)
