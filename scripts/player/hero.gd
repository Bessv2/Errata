class_name Hero
extends CharacterBody2D
## The player character: walks where PlayerInput says, faces where it aims.

## Movement numbers (data/hero/hero_stats.tres).
@export var stats: HeroStats

## Which way the hero is aiming right now (unit vector). Skills read this.
var aim_direction: Vector2 = Vector2.RIGHT

@onready var health: Health = $Health
@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _aim_indicator: Node2D = $AimIndicator
@onready var _cleave: Cleave = $Cleave


func _ready() -> void:
	add_to_group("hero")
	health.reset(stats.max_hp)
	health.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	if health.is_dead():
		return
	_move(delta)
	_update_aim()
	if PlayerInput.wants_cleave():
		_cleave.try_use(aim_direction)
	_update_animation()


# --- Movement ----------------------------------------------------------------

# Speeds up toward the input direction, or slows to a stop when there is none.
func _move(delta: float) -> void:
	var input: Vector2 = PlayerInput.get_move_vector()
	if input != Vector2.ZERO:
		velocity = velocity.move_toward(input * stats.move_speed, stats.acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, stats.deceleration * delta)
	move_and_slide()


# --- Aim ---------------------------------------------------------------------

func _update_aim() -> void:
	aim_direction = PlayerInput.get_aim_direction(global_position)
	_aim_indicator.rotation = aim_direction.angle()


# --- Death -------------------------------------------------------------------

## How dark and see-through the hero's body gets on death.
const DEAD_TINT: Color = Color(0.25, 0.2, 0.3, 0.35)
## Seconds the fade to DEAD_TINT takes.
const DEATH_FADE_TIME: float = 0.6

var _death_tween: Tween


# Stops the hero and fades their body out. The death screen takes it from here.
func _on_died() -> void:
	velocity = Vector2.ZERO
	_aim_indicator.visible = false
	_sprite.stop()
	_death_tween = create_tween()
	_death_tween.tween_property(_sprite, "modulate", DEAD_TINT, DEATH_FADE_TIME)
	CombatEvents.character_died.emit(self)


## Brings the hero back at [param at] (world position) with full hit points.
func revive(at: Vector2) -> void:
	if _death_tween:
		_death_tween.kill()
	global_position = at
	velocity = Vector2.ZERO
	health.reset(stats.max_hp)
	_sprite.modulate = Color.WHITE
	_aim_indicator.visible = true
	reset_physics_interpolation()


# --- Animation ---------------------------------------------------------------

# Picks idle/run and one of 8 facings from the aim direction.
# Sprite facing index: 0 = up-right, then clockwise to 7 = up.
func _update_animation() -> void:
	var facing: int = wrapi(roundi(aim_direction.angle() / (PI / 4.0)) + 1, 0, 8)
	var state: String = "run" if velocity.length() > 5.0 else "idle"
	var anim: StringName = StringName("%s_%d" % [state, facing])
	if _sprite.animation != anim:
		# Keep the run cycle's frame when only the facing changes.
		var frame: int = _sprite.frame
		var progress: float = _sprite.frame_progress
		var same_state: bool = String(_sprite.animation).begins_with(state)
		_sprite.play(anim)
		if same_state:
			_sprite.set_frame_and_progress(frame, progress)
