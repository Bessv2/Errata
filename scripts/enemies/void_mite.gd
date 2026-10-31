class_name VoidMite
extends CharacterBody2D
## Void Mite: chases the hero and bites after a visible wind-up.
## All numbers come from data/monsters/void_mite.tres.

enum State { CHASE, WINDUP, RECOVER, DEAD }

## Stats for this monster type.
@export var data: MonsterData

## Who to chase. Set by the spawner.
var target: Node2D

var _state: State = State.CHASE
var _state_time: float = 0.0  # seconds spent in the current state

@onready var health: Health = $Health
@onready var _visual: Node2D = $Visual


func _ready() -> void:
	add_to_group("enemies")
	health.reset(data.max_hp)
	health.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	_state_time += delta
	match _state:
		State.CHASE:
			_chase(delta)
		State.WINDUP:
			_windup(delta)
		State.RECOVER:
			_slow_down(delta)
			if _state_time >= data.bite_recovery:
				_enter(State.CHASE)
		State.DEAD:
			pass


# --- States ------------------------------------------------------------------

# Walks toward the target; starts a bite once close enough.
func _chase(delta: float) -> void:
	if not _target_alive():
		_slow_down(delta)
		return
	var to_target: Vector2 = target.global_position - global_position
	if to_target.length() <= data.bite_start_range:
		_enter(State.WINDUP)
		CombatEvents.attack_telegraphed.emit(self)
		return
	velocity = velocity.move_toward(to_target.normalized() * data.move_speed, data.acceleration * delta)
	_visual.facing = to_target.normalized()
	move_and_slide()


# Stands still and telegraphs; when the wind-up ends the bite lands if the hero is still close.
func _windup(delta: float) -> void:
	_slow_down(delta)
	_visual.windup = clampf(_state_time / data.bite_windup, 0.0, 1.0)
	if _state_time < data.bite_windup:
		return
	_visual.windup = 0.0
	if _target_alive():
		var to_target: Vector2 = target.global_position - global_position
		if to_target.length() <= data.bite_hit_range:
			_bite(to_target.normalized())
	_enter(State.RECOVER)


func _bite(direction: Vector2) -> void:
	var target_health: Health = target.get_node("Health")
	target_health.take_damage(data.bite_damage, self)
	if target.has_method("apply_knockback"):
		target.apply_knockback(direction * data.bite_knockback)
	CombatEvents.hit_landed.emit(self, target, data.bite_damage, direction)


## Shoves the mite away (e.g. from Cleave), reduced by its knockback resistance.
## It skids to a stop at its own acceleration.
func apply_knockback(push: Vector2) -> void:
	velocity += push * (1.0 - data.knockback_resistance)


# --- Helpers -----------------------------------------------------------------

func _enter(state: State) -> void:
	_state = state
	_state_time = 0.0


func _slow_down(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, data.acceleration * delta)
	move_and_slide()


func _target_alive() -> bool:
	if target == null or not is_instance_valid(target):
		return false
	var target_health: Health = target.get_node_or_null("Health")
	return target_health != null and not target_health.is_dead()


func _on_died() -> void:
	_enter(State.DEAD)
	_visual.windup = 0.0
	CombatEvents.character_died.emit(self)
	# Death effects arrive in the feel pass (step 6); for now it just disappears.
	queue_free()
