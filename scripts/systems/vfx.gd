extends Node2D
## Spawns combat particles (hit sparks, death bursts) by listening to CombatEvents.
## Lives in the level so the effects sit in the world, not on the screen.

## Spray from a monster hit by the hero, aimed away from the hero.
@export var monster_hit_fx: PackedScene
## Burst when a monster dies.
@export var monster_death_fx: PackedScene
## Spray from the hero when bitten.
@export var hero_hurt_fx: PackedScene

## Effects appear this far above a character's feet (roughly body height).
const BODY_OFFSET: Vector2 = Vector2(0, -4)


func _ready() -> void:
	CombatEvents.hit_landed.connect(_on_hit_landed)
	CombatEvents.character_died.connect(_on_character_died)


func _on_hit_landed(_attacker: Node2D, target: Node2D, _amount: int, direction: Vector2) -> void:
	if target.is_in_group("hero"):
		_spawn(hero_hurt_fx, target.global_position + Vector2(0, -12), direction)
	else:
		_spawn(monster_hit_fx, target.global_position + BODY_OFFSET, direction)


func _on_character_died(who: Node2D) -> void:
	if who.is_in_group("enemies"):
		_spawn(monster_death_fx, who.global_position + BODY_OFFSET, Vector2.RIGHT)


func _spawn(scene: PackedScene, at: Vector2, direction: Vector2) -> void:
	var fx: CPUParticles2D = scene.instantiate()
	fx.global_position = at
	fx.direction = direction
	add_child(fx)
