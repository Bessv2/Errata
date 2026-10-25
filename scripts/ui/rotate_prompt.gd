extends CanvasLayer
## Landscape lock for phone browsers (autoload "RotatePrompt").
## The Android app is locked to landscape by the project setting, but a web page
## can't force rotation, so on phones/tablets held upright this covers the screen
## with "Turn your device sideways" and pauses the game until it's turned.

const BONE: Color = Color(0.85, 0.82, 0.72)
const VOID: Color = Color(0.03, 0.02, 0.05)

var _root: Control


func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not (OS.has_feature("web_android") or OS.has_feature("web_ios")):
		queue_free()
		return
	_build()
	get_viewport().size_changed.connect(_check)
	_check()


# Builds the full-screen cover: dark background and one centred line of text.
func _build() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	var dim: ColorRect = ColorRect.new()
	dim.color = VOID
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(dim)
	var label: Label = Label.new()
	label.text = "Turn your device sideways"
	label.add_theme_color_override("font_color", BONE)
	label.add_theme_font_size_override("font_size", 24)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(label)


# Shows the cover and pauses while the screen is taller than it is wide.
func _check() -> void:
	var size: Vector2 = get_viewport().get_visible_rect().size
	var portrait: bool = size.y > size.x
	_root.visible = portrait
	get_tree().paused = portrait
