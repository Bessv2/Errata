class_name HeroStats
extends Resource
## Tunable numbers for the hero. The values live in data/hero/hero_stats.tres.

## Top walking speed, in pixels per second.
@export var move_speed: float = 90.0
## How fast the hero reaches top speed, in pixels per second per second.
@export var acceleration: float = 900.0
## How fast the hero stops when input is released, in pixels per second per second.
@export var deceleration: float = 1200.0
