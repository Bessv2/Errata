extends SceneTree
## Builds scenes/player/hero_frames.tres from the hero's PixelLab frames.
## Run after adding or replacing hero art:
##   godot --headless --path . --script res://tools/art/build_hero_frames.gd
## Frames live in assets/art/hero/<animation>/<direction>/<n>.png.

const ART_DIR: String = "res://assets/art/hero"
const OUT_PATH: String = "res://scenes/player/hero_frames.tres"

## Animation name -> playback speed (frames per second).
const ANIMATIONS: Dictionary = {
	"idle": 5.0,
	"run": 12.0,
}

## The hero picks one of 8 facings from its aim (see hero.gd _update_animation):
## index 0 = up-right, then clockwise. PixelLab names the same views by compass.
const FACINGS: Array[String] = [
	"north-east", "east", "south-east", "south", "south-west", "west", "north-west", "north",
]


func _init() -> void:
	var frames: SpriteFrames = SpriteFrames.new()
	frames.remove_animation(&"default")
	for anim: String in ANIMATIONS:
		for facing in FACINGS.size():
			var name: StringName = StringName("%s_%d" % [anim, facing])
			frames.add_animation(name)
			frames.set_animation_speed(name, ANIMATIONS[anim])
			frames.set_animation_loop(name, true)
			var dir: String = "%s/%s/%s" % [ART_DIR, anim, FACINGS[facing]]
			var i: int = 0
			while ResourceLoader.exists("%s/%d.png" % [dir, i]):
				frames.add_frame(name, load("%s/%d.png" % [dir, i]))
				i += 1
			if i == 0:
				push_error("No frames in " + dir)
	var err: Error = ResourceSaver.save(frames, OUT_PATH)
	print("Saved %s (%s)" % [OUT_PATH, error_string(err)])
	quit()
