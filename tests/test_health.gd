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
