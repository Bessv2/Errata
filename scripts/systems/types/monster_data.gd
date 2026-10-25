class_name MonsterData
extends Resource
## Tunable numbers for one monster type. Values live in data/monsters/*.tres.

@export_group("Body")
## Hit points.
@export var max_hp: int = 24
## Top chasing speed, in pixels per second.
@export var move_speed: float = 55.0
## How fast it reaches top speed, in pixels per second per second.
@export var acceleration: float = 400.0

@export_group("Bite")
## Damage dealt to the hero by one bite.
@export var bite_damage: int = 6
## The mite starts a bite when the hero is this close (pixels).
@export var bite_start_range: float = 14.0
## The bite lands only if the hero is still this close when the wind-up ends (pixels).
@export var bite_hit_range: float = 18.0
## Telegraph: how long the wind-up lasts before the bite lands (seconds).
@export var bite_windup: float = 0.45
## Pause after a bite before it can chase or bite again (seconds).
@export var bite_recovery: float = 0.6

@export_group("Group")
## Fewest mites in one spawned group.
@export var group_size_min: int = 4
## Most mites in one spawned group.
@export var group_size_max: int = 6
