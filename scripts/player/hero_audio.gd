extends Node
## Hero footsteps: plays a step sound when a foot lands in the run animation.

## The hero's animated sprite.
@export var sprite: AnimatedSprite2D
## Run-cycle frames where a foot hits the ground (10-frame cycle).
@export var step_frames: Array[int] = [2, 7]


func _ready() -> void:
	sprite.frame_changed.connect(_on_frame_changed)


func _on_frame_changed() -> void:
	if String(sprite.animation).begins_with("run") and sprite.frame in step_frames:
		Sfx.play(&"footstep")
