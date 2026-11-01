extends CanvasLayer
## Pause menu: freezes the game and offers Resume and Credits.
## Opened by Esc or controller Start (via PlayerInput.pause_requested), or the small
## pause button that shows in the top-right corner while touch is the active device.
## Esc/Start or controller B closes the credits page, then the menu.
## Credits text comes from data/ui/credits.tres.

const CREDITS: CreditsData = preload("res://data/ui/credits.tres")
## Seconds the menu takes to fade in.
const FADE_IN_TIME: float = 0.15

@onready var _pause_button: Button = $PauseButton
@onready var _root: Control = $Root
@onready var _menu: Control = $Root/Menu
@onready var _resume: Button = $Root/Menu/Resume
@onready var _credits_button: Button = $Root/Menu/Credits
@onready var _credits_page: Control = $Root/CreditsPage
@onready var _credits_text: Label = $Root/CreditsPage/Scroll/Text
@onready var _back: Button = $Root/CreditsPage/Back

# The control that had keyboard/controller focus before the menu opened (e.g. the
# death screen's button), so it gets focus back on resume.
var _focus_before: Control = null


func _ready() -> void:
	# Runs while the game is paused (it is the thing that unpauses it).
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root.visible = false
	_credits_text.text = CREDITS.text
	PlayerInput.pause_requested.connect(_on_pause_requested)
	PlayerInput.device_changed.connect(_on_device_changed)
	_on_device_changed(PlayerInput.active_device)
	_pause_button.pressed.connect(_open)
	_resume.pressed.connect(_close)
	_credits_button.pressed.connect(_show_credits)
	_back.pressed.connect(_show_menu)


# --- Opening and closing -----------------------------------------------------

func _on_pause_requested() -> void:
	if not _root.visible:
		_open()
	else:
		_go_back()


# Controller B (and other "cancel" keys that aren't the pause key) steps back.
func _unhandled_input(event: InputEvent) -> void:
	if _root.visible and event.is_action_pressed("ui_cancel") and not event.is_action("pause"):
		get_viewport().set_input_as_handled()
		_go_back()


func _open() -> void:
	if get_tree().paused:
		return  # something else (e.g. the rotate-your-phone cover) already has the game paused
	Sfx.play(&"ui_confirm")
	_focus_before = get_viewport().gui_get_focus_owner()
	get_tree().paused = true
	_pause_button.visible = false
	_root.modulate.a = 0.0
	_root.visible = true
	create_tween().tween_property(_root, "modulate:a", 1.0, FADE_IN_TIME)
	_show_menu(false)


func _close() -> void:
	Sfx.play(&"ui_confirm")
	_root.visible = false
	get_tree().paused = false
	_on_device_changed(PlayerInput.active_device)
	if is_instance_valid(_focus_before) and _focus_before.is_visible_in_tree():
		_focus_before.grab_focus()
	_focus_before = null


# From the credits page, back to the menu; from the menu, resume.
func _go_back() -> void:
	if _credits_page.visible:
		_show_menu()
	else:
		_close()


# --- Pages -------------------------------------------------------------------

func _show_menu(with_sound: bool = true) -> void:
	if with_sound:
		Sfx.play(&"ui_confirm")
	_credits_page.visible = false
	_menu.visible = true
	_resume.grab_focus()


func _show_credits() -> void:
	Sfx.play(&"ui_confirm")
	_menu.visible = false
	_credits_page.visible = true
	_back.grab_focus()


# The corner pause button is only for touch; keyboard and controller have Esc/Start.
func _on_device_changed(device: PlayerInput.Device) -> void:
	_pause_button.visible = device == PlayerInput.Device.TOUCH and not _root.visible
