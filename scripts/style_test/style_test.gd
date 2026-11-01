extends Node2D
## Style-test board: shows candidate art for each slot side by side at game scale,
## on isometric floor, with the palette for reference. A dev tool, not part of the game.
## Run the scene scenes/style_test/style_test.tscn (F6 in the editor).
## Keys: 1-5 pick a slot, Left/Right cycle that slot's candidates.
## All content comes from data/style_test/board.tres.

const BOARD: StyleBoard = preload("res://data/style_test/board.tres")
const BONE: Color = Color(0.85, 0.82, 0.72)
const SLOT_WIDTH: float = 128.0
const TILE: Vector2 = Vector2(64, 32)
## The Anvil: drop height (pixels) and loop length (seconds).
const DROP_HEIGHT: float = 90.0
const DROP_LOOP: float = 1.6

var _chosen: Array[int] = []      # which candidate each slot shows
var _selected: int = 0            # slot the arrow keys act on
var _slot_roots: Array[Node2D] = []
var _drop_time: float = 0.0


func _ready() -> void:
	for i in BOARD.slots.size():
		_chosen.append(0)
		var root: Node2D = Node2D.new()
		root.position = Vector2(SLOT_WIDTH * (i - (BOARD.slots.size() - 1) / 2.0), 10)
		add_child(root)
		_slot_roots.append(root)
	for i in BOARD.slots.size():
		_build_slot(i)
	queue_redraw()


# --- Building each slot -------------------------------------------------------

# Clears a slot and rebuilds it with its currently chosen candidate.
func _build_slot(i: int) -> void:
	var root: Node2D = _slot_roots[i]
	for child in root.get_children():
		child.queue_free()
	var slot: StyleSlot = BOARD.slots[i]
	var candidate: StyleCandidate = null
	if not slot.candidates.is_empty():
		candidate = slot.candidates[_chosen[i]]
	# Floor patch: whichever ground candidate is currently showing.
	var floor_choice: StyleCandidate = _ground_choice()
	var floor_tex: Texture2D = BOARD.floor_tile
	var floor_offset: float = BOARD.floor_offset
	var floor_tinted: bool = true
	if floor_choice != null:
		floor_tex = floor_choice.texture
		floor_offset = floor_choice.ground_offset
		floor_tinted = floor_choice.tint_as_floor
	if floor_tex != null:
		# A 2x2 diamond of tiles, centred on the slot. Back tiles first so front ones overlap.
		for cell in [Vector2(-0.5, -0.5), Vector2(0.5, -0.5), Vector2(-0.5, 0.5), Vector2(0.5, 0.5)]:
			var tile: Sprite2D = Sprite2D.new()
			tile.texture = floor_tex
			# Kenney placeholders are tinted like the arena floor; real candidates show as drawn.
			if floor_tinted:
				tile.modulate = BOARD.floor_tint
			tile.position = Vector2((cell.x - cell.y) * TILE.x / 2.0, (cell.x + cell.y) * TILE.y / 2.0) + Vector2(0, -floor_offset)
			root.add_child(tile)
	if candidate != null and slot.kind != "ground":
		var art: Node2D = _make_art(candidate)
		art.name = "Art"
		root.add_child(art)
	_add_label(root, slot.title, Vector2(0, -78), 11, BONE if i != _selected else Color(1, 0.95, 0.6))
	var caption: String = "awaiting art" if candidate == null else candidate.label
	if slot.candidates.size() > 1:
		caption += "  (%d/%d)" % [_chosen[i] + 1, slot.candidates.size()]
	_add_label(root, caption, Vector2(0, 34), 8, Color(BONE, 0.7))


# The ground candidate currently showing in the ground slot (null if none).
func _ground_choice() -> StyleCandidate:
	for i in BOARD.slots.size():
		var slot: StyleSlot = BOARD.slots[i]
		if slot.kind == "ground" and not slot.candidates.is_empty():
			return slot.candidates[_chosen[i]]
	return null


# Makes the node that shows one candidate, feet on the slot's origin.
func _make_art(candidate: StyleCandidate) -> Node2D:
	if candidate.scene != null:
		return candidate.scene.instantiate()
	if candidate.frames != null:
		var anim: AnimatedSprite2D = AnimatedSprite2D.new()
		anim.sprite_frames = candidate.frames
		anim.offset = Vector2(0, -candidate.feet_offset)
		anim.play(candidate.frames.get_animation_names()[0])
		return anim
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = candidate.texture
	sprite.offset = Vector2(0, -candidate.feet_offset)
	return sprite


func _add_label(parent: Node2D, text: String, at: Vector2, font_size: int, color: Color) -> void:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.size = Vector2(SLOT_WIDTH - 12, 28)
	label.position = at - Vector2((SLOT_WIDTH - 12) / 2.0, 0)
	parent.add_child(label)


# --- Anvil loop and keys ---------------------------------------------------------

func _process(delta: float) -> void:
	# Drop slots: the art falls from above, lands, holds, repeats.
	_drop_time = fmod(_drop_time + delta, DROP_LOOP)
	var fall: float = clampf(_drop_time / (DROP_LOOP * 0.35), 0.0, 1.0)
	for i in BOARD.slots.size():
		if BOARD.slots[i].kind == "drop":
			var art: Node2D = _slot_roots[i].get_node_or_null("Art")
			if art != null:
				art.position.y = -DROP_HEIGHT * (1.0 - fall * fall)


func _unhandled_input(event: InputEvent) -> void:
	# Dev-tool keys, read directly (this scene isn't gameplay).
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var key: Key = event.physical_keycode
	if key >= KEY_1 and key <= KEY_9 and key - KEY_1 < BOARD.slots.size():
		var old: int = _selected
		_selected = key - KEY_1
		_build_slot(old)
		_build_slot(_selected)
	elif key == KEY_LEFT or key == KEY_RIGHT:
		var count: int = BOARD.slots[_selected].candidates.size()
		if count > 1:
			_chosen[_selected] = wrapi(_chosen[_selected] + (1 if key == KEY_RIGHT else -1), 0, count)
			if BOARD.slots[_selected].kind == "ground":
				# The floor under every slot follows the ground choice.
				for i in BOARD.slots.size():
					_build_slot(i)
			else:
				_build_slot(_selected)


# --- Palette strip -------------------------------------------------------------

func _draw() -> void:
	var count: int = BOARD.palette.size()
	var swatch: Vector2 = Vector2(52, 14)
	var start: Vector2 = Vector2(-count * swatch.x / 2.0, 120)
	for i in count:
		var at: Vector2 = start + Vector2(i * swatch.x, 0)
		draw_rect(Rect2(at, swatch - Vector2(4, 0)), BOARD.palette[i])
		draw_rect(Rect2(at, swatch - Vector2(4, 0)), Color(BONE, 0.35), false, 1.0)
		if i < BOARD.palette_names.size():
			draw_string(ThemeDB.fallback_font, at + Vector2(0, 24), BOARD.palette_names[i],
					HORIZONTAL_ALIGNMENT_LEFT, swatch.x, 7, Color(BONE, 0.7))
	draw_string(ThemeDB.fallback_font, start + Vector2(0, -6), "reference swatches (not final)",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(BONE, 0.5))
	draw_string(ThemeDB.fallback_font, Vector2(-310, -165), "STYLE TEST  |  1-5 pick slot, Left/Right cycle candidates",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(BONE, 0.6))
