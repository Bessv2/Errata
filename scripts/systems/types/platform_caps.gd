class_name PlatformCaps
extends Resource
## Performance limits for one platform. Values live in data/platform/caps_*.tres.
## Phones and browsers get lower caps so they hold a playable frame rate.

## Most monsters alive at once; spawned groups are cut down to fit.
@export var max_enemies_alive: int = 60
## Particle counts are multiplied by this (1 = full, 0.5 = half).
@export_range(0.1, 1.0) var particle_scale: float = 1.0
## Most particle bursts on screen at once; extra bursts are skipped.
@export var max_particle_bursts: int = 40


## The caps for the platform the game is running on right now.
static func current() -> PlatformCaps:
	if OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios"):
		return load("res://data/platform/caps_mobile.tres")
	if OS.has_feature("web"):
		return load("res://data/platform/caps_web.tres")
	return load("res://data/platform/caps_pc.tres")
