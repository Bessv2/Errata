class_name AimAssistConfig
extends Resource
## Aim assist settings per device. Values live in data/input/aim_assist.tres.

## Mouse: off by default; the cursor is already precise.
@export var keyboard_mouse: AimAssistProfile
## Controller: right stick (or walking direction) pulled toward nearby mites.
@export var gamepad: AimAssistProfile
## Touch: there is no aim stick, so a wide cone picks the mite you're facing.
@export var touch: AimAssistProfile
