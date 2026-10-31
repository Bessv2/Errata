extends SceneTree
## Makes a calmer copy of a tile: pulls every pixel toward the tile's average
## colour (less contrast) and darkens it slightly. Used for the arena floor.
##   godot --headless --path . --script res://tools/art/soften_tile.gd -- <in.png> <out.png>

## How much of each pixel's difference from the average is kept (1 = unchanged).
const CONTRAST: float = 0.4
## Brightness multiplier applied after the contrast change.
const BRIGHTNESS: float = 0.85


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var img: Image = Image.load_from_file(ProjectSettings.globalize_path(args[0]))
	img.convert(Image.FORMAT_RGBA8)
	# --- Average colour of the visible pixels ---
	var sum: Color = Color(0, 0, 0, 0)
	var count: int = 0
	for y in img.get_height():
		for x in img.get_width():
			var c: Color = img.get_pixel(x, y)
			if c.a > 0.5:
				sum += c
				count += 1
	var mean: Color = sum / count
	# --- Pull each pixel toward it, then darken ---
	for y in img.get_height():
		for x in img.get_width():
			var c: Color = img.get_pixel(x, y)
			if c.a == 0.0:
				continue
			var o: Color = mean.lerp(c, CONTRAST) * BRIGHTNESS
			img.set_pixel(x, y, Color(o.r, o.g, o.b, c.a))
	print("Saved %s (%s)" % [args[1], error_string(img.save_png(ProjectSettings.globalize_path(args[1])))])
	quit()
