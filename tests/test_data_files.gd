extends Node
## Every data file loads, and its numbers are in sensible ranges.
## Catches typos and broken links after rebalancing in the Inspector.


func run(t: Node) -> void:
	var hero: HeroStats = load("res://data/hero/hero_stats.tres")
	t.check("hero stats load with positive HP and speed",
			hero != null and hero.max_hp > 0 and hero.move_speed > 0.0 and hero.acceleration > 0.0)

	var cleave: SkillData = load("res://data/skills/cleave.tres")
	t.check("Cleave loads with damage, reach, cooldown > 0 and arc 1-360",
			cleave != null and cleave.damage > 0 and cleave.reach > 0.0 and cleave.cooldown > 0.0
			and cleave.arc_degrees > 0.0 and cleave.arc_degrees <= 360.0)

	var mite: MonsterData = load("res://data/monsters/void_mite.tres")
	t.check("Void Mite loads with HP and bite numbers > 0",
			mite != null and mite.max_hp > 0 and mite.bite_damage > 0 and mite.bite_windup > 0.0)
	t.check("Void Mite bite lands from at least as far as it starts",
			mite.bite_hit_range >= mite.bite_start_range)
	t.check("Void Mite group size min <= max", mite.group_size_min <= mite.group_size_max)
	t.check("Void Mite is slower than the hero (so bites can be dodged)", mite.move_speed < hero.move_speed)

	t.check("spawn config loads", load("res://data/world/arena_spawns.tres") is SpawnConfig)
	t.check("respawn config loads", load("res://data/world/respawn.tres") is RespawnConfig)
	t.check("feel config loads", load("res://data/feel/feel.tres") is FeelConfig)
	t.check("touch config loads", load("res://data/input/touch_controls.tres") is TouchConfig)

	var assist: AimAssistConfig = load("res://data/input/aim_assist.tres")
	t.check("aim assist has a profile for every device",
			assist.keyboard_mouse != null and assist.gamepad != null and assist.touch != null)

	for platform in ["pc", "web", "mobile"]:
		var caps: PlatformCaps = load("res://data/platform/caps_%s.tres" % platform)
		t.check("%s caps allow at least one full Void Mite group" % platform,
				caps != null and caps.max_enemies_alive >= mite.group_size_max)

	var bank: SoundBank = load("res://data/audio/sfx_bank.tres")
	var silent: Array[String] = []
	for sound in bank.entries:
		if bank.entries[sound].streams.is_empty():
			silent.append(String(sound))
	t.check("every sound slot has at least one clip (silent: %s)" % ", ".join(silent), silent.is_empty())
