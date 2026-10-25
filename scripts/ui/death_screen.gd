extends CanvasLayer
## Death screen: dims the game and offers "Respawn nearby".
## Only UI: it asks the RespawnService to do the actual respawn.
## Works with mouse, touch (tap), keyboard (Enter/Space) and controller (A),
## because the button takes focus when the screen opens.

## Seconds the screen takes to fade in.
const FADE_IN_TIME: float = 0.4

## The game-side respawn handler in this level.
@export var respawn_service: RespawnService

@onready var _root: Control = $Root
@onready var _respawn_nearby: Button = $Root/Panel/RespawnNearby


func _ready() -> void:
	_root.visible = false
	respawn_service.death_screen_requested.connect(_open)
	_respawn_nearby.pressed.connect(_on_respawn_nearby)


func _open() -> void:
	_root.modulate.a = 0.0
	_root.visible = true
	create_tween().tween_property(_root, "modulate:a", 1.0, FADE_IN_TIME)
	_respawn_nearby.grab_focus()


func _on_respawn_nearby() -> void:
	_root.visible = false
	respawn_service.respawn_nearby()
