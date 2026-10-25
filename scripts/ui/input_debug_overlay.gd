extends CanvasLayer
## Diagnostic readout for input problems on real devices. Hidden unless the web
## page is opened with "?debug" in the address (e.g. .../Errata/?debug).
## Shows the build number, the input mode, and counts of each event type received.

var _label: Label
var _counts: Dictionary = {}
var _last: String = ""


func _ready() -> void:
	layer = 20
	var wanted: bool = false
	if OS.has_feature("web"):
		var query: Variant = JavaScriptBridge.eval("window.location.search", true)
		wanted = query is String and (query as String).contains("debug")
	if not wanted:
		queue_free()
		return
	_label = Label.new()
	_label.position = Vector2(4, 4)
	_label.add_theme_font_size_override("font_size", 9)
	_label.add_theme_color_override("font_color", Color(0.9, 0.95, 0.6))
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.add_theme_constant_override("outline_size", 3)
	add_child(_label)


func _input(event: InputEvent) -> void:
	var kind: String = event.get_class().trim_prefix("InputEvent")
	if "device" in event and event.device == InputEvent.DEVICE_ID_EMULATION:
		kind += "(emu)"
	_counts[kind] = _counts.get(kind, 0) + 1
	if event is InputEventScreenTouch:
		_last = "touch idx %d %s at %s" % [event.index, "down" if event.pressed else "up", Vector2i(event.position)]
	elif event is InputEventScreenDrag:
		_last = "drag idx %d at %s" % [event.index, Vector2i(event.position)]


func _process(_delta: float) -> void:
	var lines: PackedStringArray = []
	lines.append("build %s | mode %s" % [ProjectSettings.get_setting("application/config/version", "?"),
			PlayerInput.Device.keys()[PlayerInput.active_device]])
	lines.append("touch move %s | cleave %s" % [snapped(PlayerInput._touch_move, Vector2(0.01, 0.01)), PlayerInput._touch_cleave])
	lines.append("view %s" % Vector2i(get_viewport().get_visible_rect().size))
	lines.append(_last)
	var kinds: Array = _counts.keys()
	kinds.sort()
	for k in kinds:
		lines.append("%s: %d" % [k, _counts[k]])
	_label.text = "\n".join(lines)
