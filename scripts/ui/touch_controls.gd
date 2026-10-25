extends Control
## On-screen touch controls: a floating joystick (appears wherever the left thumb
## lands) and a large Cleave button bottom-right. Shown only while touch is the
## active device. Reports to PlayerInput; never touches the hero directly.
## Sizes come from data/input/touch_controls.tres.

const CONFIG: TouchConfig = preload("res://data/input/touch_controls.tres")
const BONE: Color = Color(0.85, 0.82, 0.72)
const BRUISE: Color = Color(0.22, 0.14, 0.3)
## Radius of the joystick's thumb knob (pixels).
const KNOB_RADIUS: float = 12.0

# Which finger (touch index) is on the joystick / button; -1 = none.
var _joy_finger: int = -1
var _button_finger: int = -1
# Where the joystick finger landed, and how far it has dragged from there.
var _joy_anchor: Vector2 = Vector2.ZERO
var _joy_offset: Vector2 = Vector2.ZERO
# Same for the Cleave button: dragging away from where the finger landed aims.
var _button_anchor: Vector2 = Vector2.ZERO
var _button_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	PlayerInput.device_changed.connect(_on_device_changed)
	visible = PlayerInput.active_device == PlayerInput.Device.TOUCH


func _on_device_changed(device: PlayerInput.Device) -> void:
	visible = device == PlayerInput.Device.TOUCH
	if not visible:
		_release_joystick()
		_release_button()


# --- Reading fingers ---------------------------------------------------------

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_on_finger_down(event.index, event.position)
		else:
			_on_finger_up(event.index)
	elif event is InputEventScreenDrag and event.index == _joy_finger:
		_joy_offset = (event.position - _joy_anchor).limit_length(CONFIG.joystick_radius)
		_report_joystick()
	elif event is InputEventScreenDrag and event.index == _button_finger:
		_button_offset = (event.position - _button_anchor).limit_length(CONFIG.aim_drag_radius)
		_report_aim()


func _on_finger_down(finger: int, at: Vector2) -> void:
	if _button_finger == -1 and at.distance_to(_button_centre()) <= CONFIG.button_radius * 1.25:
		_button_finger = finger
		_button_anchor = at
		_button_offset = Vector2.ZERO
		PlayerInput.touch_set_cleave(true)
		_report_aim()
	elif _joy_finger == -1 and at.x < size.x * CONFIG.joystick_zone:
		_joy_finger = finger
		_joy_anchor = at
		_joy_offset = Vector2.ZERO
		_report_joystick()


func _on_finger_up(finger: int) -> void:
	if finger == _joy_finger:
		_release_joystick()
	elif finger == _button_finger:
		_release_button()


func _release_joystick() -> void:
	_joy_finger = -1
	_joy_offset = Vector2.ZERO
	PlayerInput.touch_set_move(Vector2.ZERO)
	queue_redraw()


func _release_button() -> void:
	_button_finger = -1
	_button_offset = Vector2.ZERO
	PlayerInput.touch_set_cleave(false)
	PlayerInput.touch_set_aim(Vector2.ZERO)
	queue_redraw()


# Turns a drag on the Cleave button into an aim direction. Short drags don't aim,
# so a plain tap or hold still lets aim assist pick the target.
func _report_aim() -> void:
	var push: Vector2 = _button_offset / CONFIG.aim_drag_radius
	PlayerInput.touch_set_aim(push.normalized() if push.length() >= CONFIG.aim_deadzone else Vector2.ZERO)
	queue_redraw()


# Turns the drag into a 0-1 push, ignoring tiny drags (deadzone).
func _report_joystick() -> void:
	var push: Vector2 = _joy_offset / CONFIG.joystick_radius
	if push.length() < CONFIG.joystick_deadzone:
		push = Vector2.ZERO
	PlayerInput.touch_set_move(push)
	queue_redraw()


# --- Drawing -----------------------------------------------------------------

func _button_centre() -> Vector2:
	var r: float = CONFIG.button_radius
	return Vector2(size.x - CONFIG.button_margin - r, size.y - CONFIG.button_margin - r)


# Where the joystick hint sits when no thumb is down.
func _joystick_rest() -> Vector2:
	var r: float = CONFIG.joystick_radius
	return Vector2(CONFIG.button_margin + r, size.y - CONFIG.button_margin - r)


func _draw() -> void:
	_draw_joystick()
	_draw_button()


func _draw_joystick() -> void:
	var active: bool = _joy_finger != -1
	var centre: Vector2 = _joy_anchor if active else _joystick_rest()
	var alpha: float = 0.6 if active else 0.25
	draw_circle(centre, CONFIG.joystick_radius, Color(BRUISE, alpha * 0.6))
	draw_arc(centre, CONFIG.joystick_radius, 0.0, TAU, 32, Color(BONE, alpha), 1.0)
	draw_circle(centre + _joy_offset, KNOB_RADIUS, Color(BONE, alpha))


func _draw_button() -> void:
	var held: bool = _button_finger != -1
	var centre: Vector2 = _button_centre()
	var r: float = CONFIG.button_radius * (0.92 if held else 1.0)
	draw_circle(centre, r, Color(BRUISE, 0.75 if held else 0.45))
	draw_arc(centre, r, 0.0, TAU, 40, Color(BONE, 0.95 if held else 0.6), 2.0 if held else 1.0)
	var aiming: bool = held and _button_offset.length() >= CONFIG.aim_drag_radius * CONFIG.aim_deadzone
	if aiming:
		# Aim knob: shows the dragged direction, clamped to the button's rim.
		var dir: Vector2 = _button_offset.normalized()
		var knob: Vector2 = centre + dir * minf(_button_offset.length(), r)
		draw_line(centre, knob, Color(BONE, 0.6), 2.0)
		draw_circle(knob, KNOB_RADIUS * 0.8, Color(BONE, 0.95))
	else:
		# Cleave glyph: a crescent sweep, like the swing on the floor.
		draw_arc(centre + Vector2(-3, 3), r * 0.5, -PI * 0.95, -PI * 0.05, 16, Color(BONE, 0.95 if held else 0.7), 3.0)
