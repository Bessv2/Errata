extends Node
## The one input/aim layer (autoload "PlayerInput").
## Gameplay code asks this node where the player wants to move and aim.
## It never reads keyboards, mice, gamepads or touch directly.

## Which kind of device the player used most recently.
enum Device { KEYBOARD_MOUSE, GAMEPAD, TOUCH }

## Fired when the player switches device (e.g. picks up a controller).
signal device_changed(device: Device)

## Stick input below this length counts as "not touched".
const STICK_DEADZONE: float = 0.2
## Aim assist tunables, one profile per device.
const AIM_ASSIST: AimAssistConfig = preload("res://data/input/aim_assist.tres")

var active_device: Device = Device.KEYBOARD_MOUSE

## The monster aim assist is currently locked onto (null if none). Read-only for others.
var locked_target: Node2D = null

# Last non-zero aim, so a released stick keeps pointing the same way.
var _last_aim: Vector2 = Vector2.RIGHT
# Last non-zero movement, used as aim on gamepad when the right stick is idle.
var _last_move: Vector2 = Vector2.RIGHT
# What the on-screen touch controls are reporting (set via the touch_* functions).
var _touch_move: Vector2 = Vector2.ZERO
var _touch_cleave: bool = false
var _touch_aim: Vector2 = Vector2.ZERO


# --- Device detection --------------------------------------------------------

func _ready() -> void:
	# Phones and tablets start in touch mode so the on-screen controls show at once.
	if OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios"):
		active_device = Device.TOUCH


func _input(event: InputEvent) -> void:
	var device: Device = active_device
	if event is InputEventKey:
		device = Device.KEYBOARD_MOUSE
	elif event is InputEventMouseButton:
		# Phones also send fake mouse events for touches; ignore those.
		if event.device != InputEvent.DEVICE_ID_EMULATION:
			device = Device.KEYBOARD_MOUSE
	elif event is InputEventMouseMotion:
		# In the web build, browsers report finger drags as mouse movement too,
		# so movement alone never leaves touch mode; a click or key press does.
		if event.device != InputEvent.DEVICE_ID_EMULATION and active_device != Device.TOUCH:
			device = Device.KEYBOARD_MOUSE
	elif event is InputEventJoypadButton:
		device = Device.GAMEPAD
	elif event is InputEventJoypadMotion:
		if absf(event.axis_value) > STICK_DEADZONE:
			device = Device.GAMEPAD
	elif event is InputEventScreenTouch or event is InputEventScreenDrag:
		device = Device.TOUCH
	if device != active_device:
		active_device = device
		device_changed.emit(device)


# --- Questions gameplay can ask ----------------------------------------------

## Where the player wants to move, as a vector up to length 1 (screen directions).
func get_move_vector() -> Vector2:
	var move: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if active_device == Device.TOUCH:
		move = _touch_move
	if move != Vector2.ZERO:
		_last_move = move.normalized()
	return move


## True while the player is asking for Cleave (held = keep swinging).
func wants_cleave() -> bool:
	if active_device == Device.TOUCH:
		# Phones also fake a left-click on every touch; only the Cleave button counts.
		return _touch_cleave
	return Input.is_action_pressed("cleave")


# --- Touch controls report here ----------------------------------------------

## The virtual joystick's current push (length 0-1). Zero when released.
func touch_set_move(vector: Vector2) -> void:
	_touch_move = vector


## Whether the on-screen Cleave button is held.
func touch_set_cleave(held: bool) -> void:
	_touch_cleave = held


## The direction a skill button is being dragged to aim (zero = not aiming).
func touch_set_aim(direction: Vector2) -> void:
	_touch_aim = direction


## Which way the player is aiming, as a unit vector, for a character standing at
## [param origin] (world position). Includes aim assist for the active device,
## and updates locked_target. Call once per physics frame.
func get_aim_direction(origin: Vector2) -> Vector2:
	var raw: Vector2 = _raw_aim(origin)
	var profile: AimAssistProfile = _assist_profile()
	locked_target = AimAssist.pick_target(origin, raw, get_tree().get_nodes_in_group("enemies"),
			profile, locked_target if is_instance_valid(locked_target) else null)
	return AimAssist.bend_toward(origin, raw, locked_target, profile)


# The aim before assist: cursor, right stick, dragged skill button, or walking direction.
func _raw_aim(origin: Vector2) -> Vector2:
	var aim: Vector2 = Vector2.ZERO
	match active_device:
		Device.KEYBOARD_MOUSE:
			aim = _mouse_world_position() - origin
		Device.GAMEPAD:
			aim = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
			if aim == Vector2.ZERO:
				aim = _last_move
		Device.TOUCH:
			# Dragging a skill button aims; otherwise you attack the way you walk.
			aim = _touch_aim if _touch_aim != Vector2.ZERO else _last_move
	if aim.length() > 0.001:
		_last_aim = aim.normalized()
	return _last_aim


# --- Helpers -----------------------------------------------------------------

func _assist_profile() -> AimAssistProfile:
	match active_device:
		Device.GAMEPAD:
			return AIM_ASSIST.gamepad
		Device.TOUCH:
			return AIM_ASSIST.touch_aiming if _touch_aim != Vector2.ZERO else AIM_ASSIST.touch
		_:
			return AIM_ASSIST.keyboard_mouse


# The mouse position converted from screen pixels to world coordinates.
func _mouse_world_position() -> Vector2:
	var viewport: Viewport = get_viewport()
	return viewport.get_canvas_transform().affine_inverse() * viewport.get_mouse_position()
