extends SceneTree
## Makes a calmer copy of a tile: pulls every pixel toward the tile's average
## colour (less contrast), drains some colour toward plain grey, and sets the
## overall brightness. Used for the arena floor.
##   godot --headless --path . --script res://tools/art/soften_tile.gd -- <in.png> <out.png> [contrast] [saturation] [brightness]

## How much of each pixel's difference from the average is kept (1 = unchanged).
const CONTRAST: float = 0.4
## How much colour is kept (1 = unchanged, 0 = plain grey).
const SATURATION: float = 0.35
## Brightness multiplier applied last (1 = unchanged).
const BRIGHTNESS: float = 1.15


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	# Optional overrides, for trying values without editing this file.
	var contrast: float = float(args[2]) if args.size() > 2 else CONTRAST
	var saturation: float = float(args[3]) if args.size() > 3 else SATURATION
	var brightness: float = float(args[4]) if args.size() > 4 else BRIGHTNESS
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
	# --- Less contrast, less colour, then brightness ---
	for y in img.get_height():
		for x in img.get_width():
			var c: Color = img.get_pixel(x, y)
			if c.a == 0.0:
				continue
			var o: Color = mean.lerp(c, contrast)
			var grey: float = o.get_luminance()
			o = Color(grey, grey, grey).lerp(o, saturation) * brightness
			img.set_pixel(x, y, Color(clampf(o.r, 0, 1), clampf(o.g, 0, 1), clampf(o.b, 0, 1), c.a))
	print("Saved %s (%s)" % [args[1], error_string(img.save_png(ProjectSettings.globalize_path(args[1])))])
	quit()
