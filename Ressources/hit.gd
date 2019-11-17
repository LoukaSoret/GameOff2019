extends Particles

var delay : float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emitting = true
	pass # Replace with function body.

var t = 0
func _process(delta: float) -> void:
	if t>delay:
		queue_free()
	else:
		t += delta
	pass
