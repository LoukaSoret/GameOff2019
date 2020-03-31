extends Particles

var delay : float = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	pass # Replace with function body.

func activate():
	emitting = true
	set_process(true)

var t = 0
func _process(delta: float) -> void:
	if t>delay:
		pass#queue_free()
	else:
		t += delta
	pass
