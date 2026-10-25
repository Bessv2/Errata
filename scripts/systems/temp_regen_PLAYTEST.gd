extends Node
## TEMPORARY PLAYTEST PLACEHOLDER — not a designed system. Remove before Milestone 2.
## Slowly refills the hero's Health after a few seconds without taking damage.
## Numbers in data/playtest/temp_regen.tres. See TempRegenConfig for removal steps.

const CONFIG: TempRegenConfig = preload("res://data/playtest/temp_regen.tres")

## The Health to refill.
@export var health: Health

var _since_damage: float = 0.0
var _partial: float = 0.0  # fractions of an HP carried between frames


func _ready() -> void:
	health.damaged.connect(func(_amount: int, _from: Node2D) -> void: _since_damage = 0.0)


func _physics_process(delta: float) -> void:
	if not CONFIG.enabled or health.is_dead() or health.current >= health.max_hp:
		_partial = 0.0
		return
	_since_damage += delta
	if _since_damage < CONFIG.delay_after_damage:
		return
	# Only count the time past the delay (matters on the frame regen starts).
	var regen_time: float = minf(delta, _since_damage - CONFIG.delay_after_damage)
	_partial += CONFIG.hp_per_second * regen_time
	var whole: int = floori(_partial)
	if whole > 0:
		_partial -= whole
		health.current = mini(health.current + whole, health.max_hp)
