class_name SkillData
extends Resource
## Tunable numbers for a melee arc skill like Cleave. Values live in data/skills/*.tres.

## Damage dealt to every monster in the arc.
@export var damage: int = 10
## How far the arc reaches, measured on the ground (pixels).
@export var reach: float = 30.0
## How wide the arc is, in degrees, centred on the aim direction.
@export var arc_degrees: float = 150.0
## Seconds between swings while the button is held.
@export var cooldown: float = 0.4
