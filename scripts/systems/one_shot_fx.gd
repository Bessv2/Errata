extends CPUParticles2D
## A particle burst that plays once and then removes itself.


func _ready() -> void:
	finished.connect(queue_free)
	emitting = true
