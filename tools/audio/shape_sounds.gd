extends SceneTree
## Reshapes raw sound clips into the game's sound files: cut a slice, slow it down
## (deeper and heavier), soften the hiss with a low-pass filter, fade the ends,
## and optionally mix a second clip underneath. Writes 16-bit mono WAV files.
## Each output is one recipe in RECIPES below; edit a recipe and re-run:
##   godot --headless --path . --script res://tools/audio/shape_sounds.gd -- <source folder>
## The source folder holds the original pack files (from _incoming). Add --probe to
## print each source's loudness over time instead, to help choose where to cut.

## Recipe fields (all optional except src and out):
##   src: file name in the source folder; out: res:// path to write
##   start, length: seconds to cut from the source (length 0 = to the end)
##   speed: playback rate (0.7 = 30% slower and deeper)
##   lowpass_hz: cut sound above this frequency (0 = off)
##   fade_in, fade_out: seconds; gain_db: loudness change
##   peak: scale so the loudest moment reaches this level (0..1), for quiet sources
##   layer: another recipe (without out) mixed underneath, starting at layer_at seconds

## The low thump laid under both Cleave hits.
const THUMP: Dictionary = { "src": "Drs_Wood_DoubleDoor_Close_01.wav", "start": 0.05, "length": 0.35,
	"speed": 0.65, "lowpass_hz": 700.0, "fade_out": 0.15, "gain_db": 3.0 }

const RECIPES: Array[Dictionary] = [
	# Cleave swing: a fire whoosh with only the low end kept, slowed a little,
	# so it reads as a heavy hammer moving air rather than a blade.
	{ "src": "Mgc_Fire_Throw_01.wav", "out": "res://assets/audio/sfx/small_sound_kit/cleave_swing.wav",
	  "length": 0.5, "speed": 0.8, "lowpass_hz": 900.0, "fade_out": 0.15, "peak": 0.8 },
	# Cleave hits: the two bone impacts, each with a deepened wooden door slam
	# underneath so the hammer lands with weight.
	{ "src": "Impact_Guts_Gore_01.wav", "out": "res://assets/audio/sfx/small_sound_kit/cleave_hit_1.wav",
	  "length": 0.35, "lowpass_hz": 5000.0, "fade_out": 0.05, "layer": THUMP },
	{ "src": "Blood_Bone_Smash_01.wav", "out": "res://assets/audio/sfx/small_sound_kit/cleave_hit_2.wav",
	  "length": 0.6, "lowpass_hz": 5000.0, "fade_out": 0.1, "layer": THUMP },
	# Mite wind-up: a low alien drone that swells in, in place of the slurp.
	{ "src": "Drn_Alien_01.wav", "out": "res://assets/audio/sfx/small_sound_kit/mite_telegraph.wav",
	  "start": 3.3, "length": 0.5, "lowpass_hz": 2500.0, "fade_in": 0.35, "fade_out": 0.1 },
	# Mite death (second variation): a dry stick snap in place of the wet guts sound.
	{ "src": "DailySounds_Stick_Snap.wav", "out": "res://assets/audio/sfx/dailysounds/mite_death_2.wav",
	  "start": 0.6, "length": 0.35, "speed": 0.8, "lowpass_hz": 3000.0, "fade_out": 0.1 },
]


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.is_empty():
		push_error("Pass the source folder after --")
		quit(1)
		return
	var folder: String = args[0]
	if args.has("--probe"):
		_probe(folder)
	else:
		for recipe in RECIPES:
			var shaped: Dictionary = _shape(folder, recipe)
			_save(shaped, recipe["out"])
	quit()


# --- Recipes -------------------------------------------------------------------

# Returns { "rate": int, "samples": PackedFloat32Array } for one recipe (and its layer).
func _shape(folder: String, recipe: Dictionary) -> Dictionary:
	var clip: Dictionary = _load_mono(folder.path_join(recipe["src"]))
	var rate: int = clip["rate"]
	var s: PackedFloat32Array = clip["samples"]
	var start: int = int(recipe.get("start", 0.0) * rate)
	var length: int = int(recipe.get("length", 0.0) * rate)
	s = s.slice(start, start + length if length > 0 else s.size())
	s = _resample(s, recipe.get("speed", 1.0))
	if recipe.get("lowpass_hz", 0.0) > 0.0:
		s = _lowpass(s, rate, recipe["lowpass_hz"])
	s = _fade(s, int(recipe.get("fade_in", 0.0) * rate), int(recipe.get("fade_out", 0.0) * rate))
	var gain: float = db_to_linear(recipe.get("gain_db", 0.0))
	for i in s.size():
		s[i] *= gain
	if recipe.has("peak"):
		var loudest: float = 0.0
		for v in s:
			loudest = maxf(loudest, absf(v))
		for i in s.size():
			s[i] *= recipe["peak"] / maxf(loudest, 0.0001)
	if recipe.has("layer"):
		var under: Dictionary = _shape(folder, recipe["layer"])
		s = _mix(s, under["samples"], int(recipe.get("layer_at", 0.0) * rate))
	return { "rate": rate, "samples": s }


# --- Sound processing ------------------------------------------------------------

# Plays the clip at a different speed: below 1 is slower and lower in pitch.
func _resample(s: PackedFloat32Array, speed: float) -> PackedFloat32Array:
	if is_equal_approx(speed, 1.0):
		return s
	var out: PackedFloat32Array = PackedFloat32Array()
	out.resize(int(s.size() / speed))
	for i in out.size():
		var pos: float = i * speed
		var a: int = int(pos)
		var b: int = mini(a + 1, s.size() - 1)
		out[i] = lerpf(s[a], s[b], pos - a)
	return out

# Removes high frequencies (hiss, sharpness). Two passes for a steeper cut.
func _lowpass(s: PackedFloat32Array, rate: int, hz: float) -> PackedFloat32Array:
	var k: float = 1.0 - exp(-TAU * hz / rate)
	for _pass in 2:
		var y: float = 0.0
		for i in s.size():
			y += k * (s[i] - y)
			s[i] = y
	return s


func _fade(s: PackedFloat32Array, fade_in: int, fade_out: int) -> PackedFloat32Array:
	for i in mini(fade_in, s.size()):
		s[i] *= float(i) / fade_in
	for i in mini(fade_out, s.size()):
		s[s.size() - 1 - i] *= float(i) / fade_out
	return s


func _mix(top: PackedFloat32Array, under: PackedFloat32Array, at: int) -> PackedFloat32Array:
	if top.size() < at + under.size():
		top.resize(at + under.size())
	for i in under.size():
		top[at + i] += under[i]
	return top


# --- Files -----------------------------------------------------------------------

# Loads a WAV as mono floats (-1..1). Supports 16-bit PCM, mono or stereo.
func _load_mono(path: String) -> Dictionary:
	var wav: AudioStreamWAV = AudioStreamWAV.load_from_file(path)
	assert(wav.format == AudioStreamWAV.FORMAT_16_BITS, "only 16-bit WAV supported: " + path)
	var data: PackedByteArray = wav.data
	var channels: int = 2 if wav.stereo else 1
	var frames: int = data.size() / (2 * channels)
	var s: PackedFloat32Array = PackedFloat32Array()
	s.resize(frames)
	for f in frames:
		var sum: float = 0.0
		for c in channels:
			sum += data.decode_s16((f * channels + c) * 2) / 32768.0
		s[f] = sum / channels
	return { "rate": wav.mix_rate, "samples": s }

# Writes 16-bit mono, scaled down if anything would clip.
func _save(clip: Dictionary, path: String) -> void:
	var s: PackedFloat32Array = clip["samples"]
	var peak: float = 0.0
	for v in s:
		peak = maxf(peak, absf(v))
	var scale: float = 0.98 / peak if peak > 0.98 else 1.0
	var data: PackedByteArray = PackedByteArray()
	data.resize(s.size() * 2)
	for i in s.size():
		data.encode_s16(i * 2, int(clampf(s[i] * scale, -1.0, 1.0) * 32767.0))
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = clip["rate"]
	wav.stereo = false
	wav.data = data
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	print("%s: %s (%.2fs, peak %.2f)" % [path, error_string(wav.save_to_wav(ProjectSettings.globalize_path(path))), float(s.size()) / clip["rate"], peak])

# Prints each source file's loudness every 50 ms, as a bar.
func _probe(folder: String) -> void:
	for file in DirAccess.get_files_at(folder):
		if not file.ends_with(".wav"):
			continue
		var clip: Dictionary = _load_mono(folder.path_join(file))
		var s: PackedFloat32Array = clip["samples"]
		var step: int = int(clip["rate"] * 0.05)
		print("%s  %d Hz  %.2fs" % [file, clip["rate"], float(s.size()) / clip["rate"]])
		var line: String = ""
		for w in range(0, mini(s.size(), step * 80), step):
			var sum: float = 0.0
			for i in range(w, mini(w + step, s.size())):
				sum += s[i] * s[i]
			var rms: float = sqrt(sum / step)
			line += " .:-=+*#%@"[clampi(int((linear_to_db(maxf(rms, 0.000001)) + 60.0) / 6.0), 0, 9)]
		print("  |" + line + "|")
