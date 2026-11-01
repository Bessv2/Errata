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

	# Aiming with the Cleave button. A mite stands straight above the hero.
	var mite: Node2D = Node2D.new()
	mite.position = Vector2(0, -20)
	add_child(mite)
	mite.add_to_group("enemies")
	PlayerInput.locked_target = null
	PlayerInput.touch_set_aim(Vector2(-1, 0))
	var aimed: Vector2 = PlayerInput.get_aim_direction(Vector2.ZERO)
	t.check("dragging the Cleave button left aims left, not at a mite 90 deg away",
			aimed.is_equal_approx(Vector2(-1, 0)))
	PlayerInput.touch_set_aim(Vector2(0.3, -1).normalized())
	aimed = PlayerInput.get_aim_direction(Vector2.ZERO)
	t.check("dragging roughly toward a mite gets pulled onto it (lighter assist)",
			PlayerInput.locked_target == mite
			and absf(aimed.angle_to(Vector2.UP)) < absf(Vector2(0.3, -1).normalized().angle_to(Vector2.UP)))
	PlayerInput.touch_set_aim(Vector2.ZERO)
	PlayerInput.locked_target = null
	aimed = PlayerInput.get_aim_direction(Vector2.ZERO)
	t.check("without dragging, wide touch assist picks the mite to the side",
			PlayerInput.locked_target == mite and aimed.is_equal_approx(Vector2.UP))
	mite.remove_from_group("enemies")
	mite.queue_free()
	PlayerInput.locked_target = null

	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.device = 0
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	_feed(click)
	t.check("a real mouse click switches back to keyboard/mouse", PlayerInput.active_device == PlayerInput.Device.KEYBOARD_MOUSE)

	_feed(drag_as_mouse)
	t.check("in keyboard/mouse mode, mouse movement keeps it there", PlayerInput.active_device == PlayerInput.Device.KEYBOARD_MOUSE)

	PlayerInput.active_device = saved
