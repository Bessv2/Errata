class_name SpawnConfig
extends Resource
## How the arena spawns monster groups. Values live in data/world/arena_spawns.tres.

## Seconds between a group being cleared and the next one appearing.
@export var respawn_delay: float = 2.0
## New groups never appear closer than this to the hero (pixels).
@export var min_distance_from_hero: float = 140.0
## Group members are scattered within this radius of the group's centre (pixels).
@export var group_radius: float = 28.0
## Floor cells this close to the arena edge are never used for spawning.
@export var edge_margin_cells: int = 2
