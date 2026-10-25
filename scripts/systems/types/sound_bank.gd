class_name SoundBank
extends Resource
## Every sound the game can play, by name. Values live in data/audio/sfx_bank.tres.

@export var entries: Dictionary[StringName, SoundEntry] = {}
