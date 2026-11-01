extends Node
## Sound bank: a sound with a minimum gap (the mite wind-up) plays once when a
## whole pack triggers it together, and sounds without a gap always play.


func run(t: Node) -> void:
	var gap: float = (Sfx.BANK.entries[&"mite_telegraph"] as SoundEntry).min_interval
	t.check("mite wind-up has a minimum gap set in data", gap > 0.0)

	# Five mites winding up in the same moment: only the first starts a voice.
	var before: int = Sfx._next
	for i in 5:
		Sfx.play(&"mite_telegraph")
	t.check("a pack winding up together plays the wind-up once", Sfx._next == (before + 1) % Sfx.VOICES)

	# The swing has no gap, so two quick swings both play.
	before = Sfx._next
	Sfx.play(&"cleave_swing")
	Sfx.play(&"cleave_swing")
	t.check("sounds without a gap play every time", Sfx._next == (before + 2) % Sfx.VOICES)

	for player in Sfx._players:
		player.stop()
