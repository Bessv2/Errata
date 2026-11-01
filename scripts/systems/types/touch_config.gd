class_name TouchConfig
extends Resource
## On-screen touch controls. Values live in data/input/touch_controls.tres.
## Sizes are in game pixels (the 640x360 base view), so they scale with the screen.

@export_group("Joystick")
## The joystick appears wherever a thumb lands in this share of the screen, from the left.
@export_range(0.1, 0.9) var joystick_zone: float = 0.5
## How far the thumb can drag from where it landed for full speed (pixels).
@export var joystick_radius: float = 36.0
## Drags shorter than this share of the radius count as "not moving".
@export_range(0.0, 0.5) var joystick_deadzone: float = 0.15

@export_group("Cleave button")
## Button radius (pixels). Large on purpose: thumbs are imprecise.
@export var button_radius: float = 32.0
## Gap between the button's edge and the bottom-right corner of the screen (pixels).
@export var button_margin: float = 22.0
## Dragging this far from the button's centre aims fully in that direction (pixels).
@export var aim_drag_radius: float = 32.0
## Drags shorter than this share of aim_drag_radius don't aim (aim assist picks instead).
@export_range(0.0, 0.9) var aim_deadzone: float = 0.3
