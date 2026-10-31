extends SceneTree
## Balance simulation: the hero fights Void Mite packs with Cleave, 10,000 times per scenario.
## Reads the real data files, so it always tests the current numbers.
## Run from the project folder:
##   godot --headless --path . --script res://tools/sim/cleave_sim.gd
##
## Model (simple on purpose; checked against driven runs of the real game):
## - The fight starts when the pack reaches the hero; the hero stands still and swings
##   every Cleave cooldown.
## - Each swing hits each living mite with chance HIT_CHANCE (aim quality + crowding).
## - At most MAX_BITERS mites can reach the hero at once. A biter winds up, bites, recovers,
##   then needs REAPPROACH seconds to get back in range.
## - A mite hit by Cleave during its wind-up is knocked out of range: that bite misses.

const FIGHTS: int = 10000
const STEP: float = 0.02
## How many mites can crowd the hero at once.
const MAX_BITERS: int = 3
## Seconds a mite needs to get back in range after biting or being knocked back.
const REAPPROACH: float = 0.3

var hero: HeroStats = load("res://data/hero/hero_stats.tres")
var cleave: SkillData = load("res://data/skills/cleave.tres")
var mite: MonsterData = load("res://data/monsters/void_mite.tres")
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init() -> void:
	rng.seed = 12345
	print("Cleave: %d dmg every %.2fs | Void Mite: %d HP, bites %d after %.2fs wind-up | hero %d HP" % [
		cleave.damage, cleave.cooldown, mite.max_hp, mite.bite_damage, mite.bite_windup, hero.max_hp])
	print("Hits to kill one mite: %d\n" % ceili(float(mite.max_hp) / cleave.damage))
	_scenario("Good aim (each swing catches 60% of the pack)", 0.6, true)
	_scenario("Sloppy aim (35% of the pack per swing)", 0.35, true)
	_scenario("Not attacking (how fast a pack kills you)", 0.0, false)
	_life_with_temp_regen(0.6, "good aim")
	_life_with_temp_regen(0.35, "sloppy aim")
	quit()


## TEMPORARY playtest regen check: fight pack after pack with out-of-combat regen
## between them, and count how many packs a life lasts (capped at 50).
## Gap between packs = respawn delay + the new group walking in from its spawn distance.
func _life_with_temp_regen(hit_chance: float, label: String) -> void:
	var regen: TempRegenConfig = load("res://data/playtest/temp_regen.tres")
	var spawns: SpawnConfig = load("res://data/world/arena_spawns.tres")
	var gap: float = spawns.respawn_delay + spawns.min_distance_from_hero / mite.move_speed
	var regen_per_gap: float = maxf(gap - regen.delay_after_damage, 0.0) * regen.hp_per_second
	var lives: Array[float] = []
	for i in 2000:
		var hp: float = hero.max_hp
		var packs: int = 0
		while packs < 50:
			var r: Dictionary = _fight(hit_chance, true)
			hp -= r.damage
			if hp <= 0.0:
				break
			packs += 1
			hp = minf(hp + regen_per_gap, hero.max_hp)
		lives.append(packs)
	lives.sort()
	print("== TEMP regen (%s): %.1fs between packs, %.0f HP back per gap" % [label, gap, regen_per_gap])
	print("  packs per life   median %d   (worst 10%%: %d or fewer; 50 = cap)\n" % [lives[1000], lives[200]])


func _scenario(title: String, hit_chance: float, attacking: bool) -> void:
	var times: Array[float] = []
	var damage: Array[float] = []
	var swings: Array[float] = []
	var deaths: int = 0
	for i in FIGHTS:
		var r: Dictionary = _fight(hit_chance, attacking)
		times.append(r.time)
		damage.append(r.damage)
		swings.append(r.swings)
		if r.hero_died:
			deaths += 1
	times.sort()
	damage.sort()
	print("== ", title)
	if attacking:
		print("  pack cleared in   median %.1fs   (90%% of fights under %.1fs)" % [times[FIGHTS / 2], times[FIGHTS * 9 / 10]])
		print("  swings needed     average %.1f" % _mean(swings))
		print("  damage taken      median %d HP   (worst 10%%: %d+ HP)" % [damage[FIGHTS / 2], damage[FIGHTS * 9 / 10]])
		print("  packs per life    about %.1f   (from full HP, no healing)" % (hero.max_hp / maxf(_mean(damage), 0.01)))
		print("  hero died in one pack: %.2f%% of fights\n" % (100.0 * deaths / FIGHTS))
	else:
		print("  hero dies after   median %.1fs\n" % times[FIGHTS / 2])


# One fight. Returns time, damage taken, swings and whether the hero died.
func _fight(hit_chance: float, attacking: bool) -> Dictionary:
	var count: int = rng.randi_range(mite.group_size_min, mite.group_size_max)
	var hp: Array[int] = []
	var state: Array[String] = []      # "wait" | "windup" | "recover"
	var timer: Array[float] = []
	for i in count:
		hp.append(mite.max_hp)
		state.append("wait")
		timer.append(rng.randf_range(0.0, REAPPROACH))  # they arrive slightly apart
	var hero_hp: int = hero.max_hp
	var t: float = 0.0
	var next_swing: float = 0.0
	var swings: int = 0
	while t < 60.0:
		# Hero swings.
		if attacking and t >= next_swing:
			next_swing = t + cleave.cooldown
			swings += 1
			for i in count:
				if hp[i] > 0 and rng.randf() < hit_chance:
					hp[i] -= cleave.damage
					if state[i] == "windup":  # knocked out of range: bite cancelled
						state[i] = "wait"
						timer[i] = REAPPROACH
		if attacking and hp.all(func(h: int) -> bool: return h <= 0):
			break
		# Mites act.
		var biters: int = 0
		for i in count:
			if hp[i] > 0 and state[i] == "windup":
				biters += 1
		for i in count:
			if hp[i] <= 0:
				continue
			timer[i] -= STEP
			if timer[i] > 0.0:
				continue
			match state[i]:
				"wait":
					if biters < MAX_BITERS:
						state[i] = "windup"
						timer[i] = mite.bite_windup
						biters += 1
				"windup":
					hero_hp -= mite.bite_damage
					state[i] = "recover"
					timer[i] = mite.bite_recovery
				"recover":
					state[i] = "wait"
					timer[i] = REAPPROACH
		if hero_hp <= 0:
			break
		t += STEP
	return {"time": t, "damage": hero.max_hp - maxi(hero_hp, 0), "swings": swings, "hero_died": hero_hp <= 0}


func _mean(values: Array[float]) -> float:
	var total: float = 0.0
	for v in values:
		total += v
	return total / values.size()
