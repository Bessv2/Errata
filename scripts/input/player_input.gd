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

var active_device: Device = Device.KEYBOARD_MOUSE

# Last non-zero aim, so a released stick keeps pointing the same way.
var _last_aim: Vector2 = Vector2.RIGHT
# Last non-zero movement, used as aim on gamepad when the right stick is idle.
var _last_move: Vector2 = Vector2.RIGHT


# --- Device detection --------------------------------------------------------

func _input(event: InputEvent) -> void:
	var device: Device = active_device
	if event is InputEventKey:
		device = Device.KEYBOARD_MOUSE
	elif event is InputEventMouseButton or event is InputEventMouseMotion:
		# Phones also send fake mouse events for touches; ignore those.
		if event.device != InputEvent.DEVICE_ID_EMULATION:
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
	if move != Vector2.ZERO:
		_last_move = move.normalized()
	return move


## True while the player is asking for Cleave (held = keep swinging).
func wants_cleave() -> bool:
	return Input.is_action_pressed("cleave")


## Which way the player is aiming, as a unit vector, for a character standing at
## [param origin] (world position).
func get_aim_direction(origin: Vector2) -> Vector2:
	var aim: Vector2 = Vector2.ZERO
	match active_device:
		Device.KEYBOARD_MOUSE:
			aim = _mouse_world_position() - origin
		Device.GAMEPAD:
			aim = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
			if aim == Vector2.ZERO:
				aim = _last_move
		Device.TOUCH:
			# Touch has no aim stick; you attack the way you walk (aim assist arrives in step 7).
			aim = _last_move
	if aim.length() > 0.001:
		_last_aim = aim.normalized()
	return _last_aim


# --- Helpers -----------------------------------------------------------------

# The mouse position converted from screen pixels to world coordinates.
func _mouse_world_position() -> Vector2:
	var viewport: Viewport = get_viewport()
	return viewport.get_canvas_transform().affine_inverse() * viewport.get_mouse_position()
