extends Node
## Touch input mode. In the web build, browsers report finger drags as mouse
## movement too, so mouse movement must not knock the game out of touch mode
## (that broke the joystick on phones).


func _feed(event: InputEvent) -> void:
	PlayerInput._input(event)


func run(t: Node) -> void:
	var saved: PlayerInput.Device = PlayerInput.active_device

	var touch: InputEventScreenTouch = InputEventScreenTouch.new()
	touch.pressed = true
	_feed(touch)
	t.check("a finger touch switches to touch mode", PlayerInput.active_device == PlayerInput.Device.TOUCH)

	# What a phone browser sends while a finger drags: real (non-emulated) mouse motion.
	var drag_as_mouse: InputEventMouseMotion = InputEventMouseMotion.new()
	drag_as_mouse.device = 0
	drag_as_mouse.relative = Vector2(12, 0)
	_feed(drag_as_mouse)
	t.check("mouse movement from a finger drag keeps touch mode", PlayerInput.active_device == PlayerInput.Device.TOUCH)

	PlayerInput.touch_set_move(Vector2(1, 0))
	t.check("joystick push becomes the move vector", PlayerInput.get_move_vector() == Vector2(1, 0))
	PlayerInput.touch_set_move(Vector2.ZERO)

	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.device = 0
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	_feed(click)
	t.check("a real mouse click switches back to keyboard/mouse", PlayerInput.active_device == PlayerInput.Device.KEYBOARD_MOUSE)

	_feed(drag_as_mouse)
	t.check("in keyboard/mouse mode, mouse movement keeps it there", PlayerInput.active_device == PlayerInput.Device.KEYBOARD_MOUSE)

	PlayerInput.active_device = saved
