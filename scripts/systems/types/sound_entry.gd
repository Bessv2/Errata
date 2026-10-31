class_name SoundEntry
extends Resource
## One named sound in the sound bank: a few variations picked at random,
## with a volume and a little random pitch so repeats don't sound robotic.

## Variations; one is picked at random each time. Empty = silent for now.
@export var streams: Array[AudioStream] = []
## Loudness in decibels (0 = as recorded, -6 = about half as loud).
@export var volume_db: float = 0.0
## Random pitch change each play, e.g. 0.08 = up to 8% higher or lower.
@export var pitch_variance: float = 0.08
