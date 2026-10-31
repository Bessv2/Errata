extends Node
## Automated test runner. Run headless from the project folder:
##   godot --headless --path . res://tests/run_tests.tscn
## Runs every test_*.gd in tests/, prints PASS/FAIL per check, and exits with
## code 1 if anything failed (so a build script can stop on failure).

var _passed: int = 0
var _failed: int = 0


func _ready() -> void:
	for file in DirAccess.get_files_at("res://tests"):
		if file.begins_with("test_") and file.ends_with(".gd"):
			print("\n== ", file)
			var suite: Node = (load("res://tests/" + file) as GDScript).new()
			add_child(suite)
			await suite.run(self)
			suite.queue_free()
	print("\n%d passed, %d failed" % [_passed, _failed])
	get_tree().quit(1 if _failed > 0 else 0)


## Records one check. Tests call this.
func check(label: String, ok: bool) -> void:
	if ok:
		_passed += 1
		print("  PASS  ", label)
	else:
		_failed += 1
		print("  FAIL  ", label)
