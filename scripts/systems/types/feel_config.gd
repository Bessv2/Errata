class_name FeelConfig
extends Resource
## Game-feel numbers: hit-stop, screen shake, hit flash.
## Values live in data/feel/feel.tres. Knockback strength lives with each skill
## or monster; the victim's own acceleration decides how fast it recovers.

@export_group("Hit-stop")
## Seconds the game freezes when Cleave lands (once per swing, however many it hits).
@export var hit_stop_cleave: float = 0.05
## Seconds the game freezes when the hero is bitten.
@export var hit_stop_hero_hurt: float = 0.08
## Game speed during a freeze (0 = full stop, 1 = no freeze).
@export var hit_stop_time_scale: float = 0.05

@export_group("Screen shake")
## Shake added when Cleave lands (0-1; trauma squared drives the shake).
@export var shake_cleave_hit: float = 0.3
## Shake added per extra monster hit by the same swing.
@export var shake_per_extra_hit: float = 0.05
## Shake added when the hero is bitten.
@export var shake_hero_hurt: float = 0.5
## Shake added when a monster dies.
@export var shake_monster_death: float = 0.15
## Shake added when the hero dies.
@export var shake_hero_death: float = 0.7
## Largest camera offset at full shake (pixels).
@export var shake_max_offset: float = 6.0
## How fast shake fades (trauma per second).
@export var shake_decay: float = 2.5

@export_group("Hit flash")
## Seconds a hit character flashes.
@export var flash_time: float = 0.09
