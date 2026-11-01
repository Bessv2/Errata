extends Node
## Pause menu: the pause key opens it and freezes the game, Credits shows the
## credits text, and the pause key steps back (credits -> menu -> resumed).


func _press_pause() -> void:
	var esc: InputEventAction = InputEventAction.new()
	esc.action = &"pause"
	esc.pressed = true
	PlayerInput._input(esc)


func run(t: Node) -> void:
	var menu: CanvasLayer = (load("res://scenes/ui/pause_menu.tscn") as PackedScene).instantiate()
	add_child(menu)
	var root: Control = menu.get_node("Root")
	var credits_page: Control = menu.get_node("Root/CreditsPage")

	_press_pause()
	t.check("pause key opens the menu and pauses the game", root.visible and get_tree().paused)

	(menu.get_node("Root/Menu/Credits") as Button).pressed.emit()
	var text: String = (menu.get_node("Root/CreditsPage/Scroll/Text") as Label).text
	t.check("Credits shows the credits page", credits_page.visible)
	t.check("credits include the required DailySounds CC BY line", text.contains("DailySounds") and text.contains("CC BY 4.0"))

	_press_pause()
	t.check("pause key on the credits page goes back to the menu", root.visible and not credits_page.visible)

	_press_pause()
	t.check("pause key on the menu resumes the game", not root.visible and not get_tree().paused)

	get_tree().paused = false
	menu.free()
