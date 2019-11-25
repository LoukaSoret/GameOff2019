extends Spatial

# solve freeze at first shader compilation
# from https://www.youtube.com/watch?v=Cg4ZT6X0ghs

var count_down = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if count_down > 0:
		count_down = count_down-1
		if count_down<=0:
			visible=false
