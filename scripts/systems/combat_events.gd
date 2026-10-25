extends Node
## Signal hub for combat (autoload "CombatEvents").
## Combat code announces what happened here; feel systems (hit-stop, shake, sound,
## particles) listen, so the two never call each other directly.

## Someone dealt damage. [param direction] points from attacker to target.
signal hit_landed(attacker: Node2D, target: Node2D, amount: int, direction: Vector2)
## Someone used a skill (fires on every swing, even ones that hit nothing).
signal skill_used(user: Node2D, skill: StringName, direction: Vector2)
## A monster started a telegraphed attack.
signal attack_telegraphed(attacker: Node2D)
## A character's hit points reached zero.
signal character_died(who: Node2D)
## A dead character came back (the hero respawning).
signal character_revived(who: Node2D)
