extends Node
## Hit-stop (autoload "HitStop"): freezes the game for a few hundredths of a second
## when a hit lands, so impacts feel heavy. Listens to CombatEvents.
## One swing that hits five monsters freezes once, not five times.

const FEEL: FeelConfig = preload("res://data/feel/feel.tres")

# Real-time moment (ms) the current freeze ends.
var _until_ms: int = 0


func _ready() -> void:
	# Keep running while the game is slowed or paused, so the freeze always ends.
	process_mode = Node.PROCESS_MODE_ALWAYS
	CombatEvents.hit_landed.connect(_on_hit_landed)


func _on_hit_landed(attacker: Node2D, target: Node2D, _amount: int, _direction: Vector2) -> void:
	if target.is_in_group("hero"):
		freeze(FEEL.hit_stop_hero_hurt)
	elif attacker != null and attacker.is_in_group("hero"):
		freeze(FEEL.hit_stop_cleave)


## Slows the game to near-zero for [param seconds] of real time.
## A freeze already running longer is left alone (freezes never stack).
func freeze(seconds: float) -> void:
	var end_ms: int = Time.get_ticks_msec() + int(seconds * 1000.0)
	if end_ms <= _until_ms:
		return
	_until_ms = end_ms
	Engine.time_scale = FEEL.hit_stop_time_scale


func _process(_delta: float) -> void:
	if Engine.time_scale < 1.0 and Time.get_ticks_msec() >= _until_ms:
		Engine.time_scale = 1.0
