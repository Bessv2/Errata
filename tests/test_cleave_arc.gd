extends Node
## Cleave's arc: who is inside it, measured on the isometric ground.


func run(t: Node) -> void:
	var cases: Array = [
		[Vector2(20, 0), true, "in front, 20px"],
		[Vector2(35, 0), false, "in front but past reach (35px)"],
		[Vector2(0, 12), false, "straight below: 90 deg off aim, outside a 150 deg arc"],
		[Vector2(8, 10), true, "down-right: 68 deg off aim, 21 ground px"],
		[Vector2(-20, 0), false, "behind"],
		[Vector2(0, 0), true, "standing on top of the hero"],
	]
	var nodes: Array[Node] = []
	for c in cases:
		var n: Node2D = Node2D.new()
		n.position = c[0]
		add_child(n)
		nodes.append(n)
	var hit: Array[Node2D] = Cleave.targets_in_arc(Vector2.ZERO, Vector2.RIGHT, nodes, 30.0, 150.0)
	for i in cases.size():
		t.check(cases[i][2], (nodes[i] in hit) == cases[i][1])
