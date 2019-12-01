extends AudioStreamPlayer

onready var musiqueLoop = get_parent().get_node("MusiqueLoop")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play()
	musiqueLoop.volume_db = -80
	musiqueLoop.play(0)
	connect("finished",self,"startLoop")
	pass # Replace with function body.

var count = 2
func _process(delta: float) -> void:
	if count>0:
		count = count-1
		if count<=0:
			musiqueLoop.stop()

func startLoop():
	musiqueLoop.volume_db = 0
	musiqueLoop.play(0)
	pass