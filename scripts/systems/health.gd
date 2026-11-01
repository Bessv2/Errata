class_name Health
extends Node
## Hit points for whatever it's attached to. The owner sets max_hp from its data on spawn.

## Fired after damage is taken. [param from] is whoever dealt it (may be null).
signal damaged(amount: int, from: Node2D)
## Fired once when hit points reach zero.
signal died

var max_hp: int = 1
var current: int = 1


## Sets maximum hit points and fills them up.
func reset(new_max: int) -> void:
	max_hp = new_max
	current = new_max


func is_dead() -> bool:
	return current <= 0


## Removes hit points. Does nothing if already dead.
func take_damage(amount: int, from: Node2D = null) -> void:
	if is_dead():
		return
	current = maxi(current - amount, 0)
	damaged.emit(amount, from)
	if current == 0:
		died.emit()
