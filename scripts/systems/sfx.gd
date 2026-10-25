extends Node
## Sound effects (autoload "Sfx"). Plays named sounds from data/audio/sfx_bank.tres.
## Combat sounds are triggered by listening to CombatEvents; other code may call play().

const BANK: SoundBank = preload("res://data/audio/sfx_bank.tres")
## How many sounds can play at once.
const VOICES: int = 12

var _players: Array[AudioStreamPlayer] = []
var _next: int = 0
# Frame of the last Cleave hit sound, so one swing hitting five mites plays once.
var _last_hit_frame: int = -1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in VOICES:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)
	CombatEvents.skill_used.connect(_on_skill_used)
	CombatEvents.hit_landed.connect(_on_hit_landed)
	CombatEvents.attack_telegraphed.connect(func(_who: Node2D) -> void: play(&"mite_telegraph"))
	CombatEvents.character_died.connect(_on_character_died)
	CombatEvents.character_revived.connect(func(_who: Node2D) -> void: play(&"hero_respawn"))


## Plays the named sound. Unknown or empty names are silently skipped.
func play(sound: StringName) -> void:
	var entry: SoundEntry = BANK.entries.get(sound)
	if entry == null or entry.streams.is_empty():
		return
	var player: AudioStreamPlayer = _players[_next]
	_next = (_next + 1) % VOICES
	player.stream = entry.streams.pick_random()
	player.volume_db = entry.volume_db
	player.pitch_scale = 1.0 + randf_range(-entry.pitch_variance, entry.pitch_variance)
	player.play()


# --- Combat → sound ------------------------------------------------------------

func _on_skill_used(_user: Node2D, skill: StringName, _direction: Vector2) -> void:
	if skill == &"cleave":
		play(&"cleave_swing")


func _on_hit_landed(attacker: Node2D, target: Node2D, _amount: int, _direction: Vector2) -> void:
	if target.is_in_group("hero"):
		play(&"hero_hurt")
	elif attacker != null and attacker.is_in_group("hero"):
		var frame: int = Engine.get_physics_frames()
		if frame != _last_hit_frame:
			play(&"cleave_hit")
		_last_hit_frame = frame


func _on_character_died(who: Node2D) -> void:
	play(&"hero_death" if who.is_in_group("hero") else &"mite_death")
