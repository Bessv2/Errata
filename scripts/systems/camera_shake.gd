extends Camera2D
## Screen shake for the hero's camera. Combat events add "trauma" (0-1);
## the camera offset grows with trauma squared, so small hits nudge and big ones jolt.
## Numbers in data/feel/feel.tres.

const FEEL: FeelConfig = preload("res://data/feel/feel.tres")

var _trauma: float = 0.0
# Frame number of the last Cleave hit, so extra hits in one swing add less.
var _last_hit_frame: int = -1


func _ready() -> void:
	CombatEvents.hit_landed.connect(_on_hit_landed)
	CombatEvents.character_died.connect(_on_character_died)


## Adds shake. 1.0 is the strongest possible.
func add_trauma(amount: float) -> void:
	_trauma = minf(_trauma + amount, 1.0)


func _process(delta: float) -> void:
	if _trauma <= 0.0:
		offset = Vector2.ZERO
		return
	_trauma = maxf(_trauma - FEEL.shake_decay * delta, 0.0)
	var strength: float = _trauma * _trauma * FEEL.shake_max_offset
	offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * strength


# --- What shakes, and how much ---------------------------------------------

func _on_hit_landed(attacker: Node2D, target: Node2D, _amount: int, _direction: Vector2) -> void:
	if target.is_in_group("hero"):
		add_trauma(FEEL.shake_hero_hurt)
	elif attacker != null and attacker.is_in_group("hero"):
		var frame: int = Engine.get_physics_frames()
		add_trauma(FEEL.shake_per_extra_hit if frame == _last_hit_frame else FEEL.shake_cleave_hit)
		_last_hit_frame = frame


func _on_character_died(who: Node2D) -> void:
	add_trauma(FEEL.shake_hero_death if who.is_in_group("hero") else FEEL.shake_monster_death)
