class_name TempRegenConfig
extends Resource
## TEMPORARY PLAYTEST PLACEHOLDER — not a designed system.
## Slow out-of-combat health regen so the Milestone 1 playtest is about combat feel,
## not attrition. Real healing gets designed before Milestone 2.
## To remove: delete this file, data/playtest/temp_regen.tres,
## scripts/systems/temp_regen_PLAYTEST.gd and the "TempRegen_PLAYTEST" node in the hero scene.

## Master switch.
@export var enabled: bool = true
## Seconds without taking damage before regen starts ("out of combat").
@export var delay_after_damage: float = 2.0
## Hit points restored per second once regen has started.
@export var hp_per_second: float = 12.0
