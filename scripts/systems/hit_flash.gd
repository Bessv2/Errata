class_name HitFlash
extends Node
## Makes a character flash when its Health takes damage.
## The target's material must use scenes/fx/hit_flash.gdshader.

const FEEL: FeelConfig = preload("res://data/feel/feel.tres")

## The sprite or drawing to flash.
@export var target: CanvasItem
## The Health to listen to.
@export var health: Health
## Flash colour (white for monsters, blood red for the hero).
@export var color: Color = Color.WHITE

var _tween: Tween


func _ready() -> void:
	var mat: ShaderMaterial = target.material as ShaderMaterial
	mat.set_shader_parameter("flash_color", color)
	health.damaged.connect(_on_damaged)


func _on_damaged(_amount: int, _from: Node2D) -> void:
	var mat: ShaderMaterial = target.material as ShaderMaterial
	if _tween:
		_tween.kill()
	mat.set_shader_parameter("flash_amount", 1.0)
	_tween = create_tween()
	# Ignore hit-stop slow-motion so the flash length is the same every time.
	_tween.set_ignore_time_scale(true)
	_tween.tween_method(func(v: float) -> void: mat.set_shader_parameter("flash_amount", v),
			1.0, 0.0, FEEL.flash_time)
