class_name AimAssistConfig
extends Resource
## Aim assist settings per device. Values live in data/input/aim_assist.tres.

## Mouse: off by default; the cursor is already precise.
@export var keyboard_mouse: AimAssistProfile
## Controller: right stick (or walking direction) pulled toward nearby mites.
@export var gamepad: AimAssistProfile
## Touch, not aiming: a wide cone picks the mite you're walking toward.
@export var touch: AimAssistProfile
## Touch, while dragging a skill button to aim: lighter, so your aim stays yours.
@export var touch_aiming: AimAssistProfile
