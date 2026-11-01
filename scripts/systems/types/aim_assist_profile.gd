class_name AimAssistProfile
extends Resource
## Aim assist settings for one kind of device (mouse, controller or touch).
## Lives inside data/input/aim_assist.tres.

## Turn aim assist on or off for this device.
@export var enabled: bool = true
## Only monsters this close are considered, measured on the ground (pixels).
@export var radius: float = 70.0
## Only monsters within this many degrees of where the player is aiming are considered.
@export var cone_degrees: float = 70.0
## How far the aim is pulled toward the chosen monster (0 = not at all, 1 = straight at it).
@export_range(0.0, 1.0) var snap_strength: float = 0.8
## How strongly the current target is kept over a slightly better one (0 = switch freely,
## 1 = never switch while it stays in range). Stops the aim flickering between mites.
@export_range(0.0, 1.0) var lock_stickiness: float = 0.4
## How much closer (as a share of score) distance counts compared with angle.
## 0 = pick by angle only, 1 = pick by distance only.
@export_range(0.0, 1.0) var distance_weight: float = 0.4
