class_name RespawnConfig
extends Resource
## Death and respawn numbers. Values live in data/world/respawn.tres.

## Seconds between the hero dying and the death screen appearing.
@export var death_screen_delay: float = 1.0
## "Respawn nearby" picks the closest floor spot at least this far from every monster (pixels).
@export var min_enemy_distance: float = 90.0
## Floor cells this close to the arena edge are never used for respawning.
@export var edge_margin_cells: int = 1
