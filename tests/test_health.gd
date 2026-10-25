extends Node
## Health: damage, death fires once, never goes below zero.


func run(t: Node) -> void:
	var h: Health = Health.new()
	add_child(h)
	h.reset(24)
	var deaths: Array[int] = [0]
	h.died.connect(func() -> void: deaths[0] += 1)
	h.take_damage(10)
	t.check("24 HP minus 10 leaves 14", h.current == 14)
	h.take_damage(20)
	t.check("overkill stops at 0, not negative", h.current == 0)
	h.take_damage(5)
	t.check("'died' fires exactly once", deaths[0] == 1)
	h.reset(100)
	t.check("reset refills and revives", h.current == 100 and not h.is_dead())

	# TEMPORARY playtest regen: waits after damage, then refills; never overfills.
	var cfg: TempRegenConfig = load("res://data/playtest/temp_regen.tres")
	var regen: Node = (load("res://scripts/systems/temp_regen_PLAYTEST.gd") as GDScript).new()
	regen.set("health", h)
	add_child(regen)
	h.take_damage(50)
	regen._physics_process(cfg.delay_after_damage * 0.5)
	t.check("[temp regen] nothing during the out-of-combat delay", h.current == 50)
	regen._physics_process(cfg.delay_after_damage * 0.5 + 0.01)
	regen._physics_process(2.0)
	t.check("[temp regen] refills about %d HP per second after the delay" % cfg.hp_per_second,
			absi(h.current - (50 + roundi(cfg.hp_per_second * 2.0))) <= 1)
	regen._physics_process(60.0)
	t.check("[temp regen] never goes above max HP", h.current == h.max_hp)
