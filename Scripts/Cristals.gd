extends Spatial

signal victory()

class_name Cristals

var nbMaxCristaux = 0
var nbCristaux = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nbMaxCristaux = get_child_count()-1
	setnbCristaux(0)
	pass # Replace with function body.

func setnbCristaux(v):
	nbCristaux = v
	$CristalsHud/Label.text = String(v) + "/" + String(nbMaxCristaux)
	
func addOne():
	setnbCristaux(nbCristaux+1)
	if nbCristaux >= nbMaxCristaux:
		emit_signal("victory")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
