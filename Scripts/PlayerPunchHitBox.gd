extends Area

var punch_big : bool = false

func _ready():
	connect("area_entered",self,"_on_area_entered")

# the player hits a ennemis with a punch
func _on_area_entered(ennemy : Area):
	if punch_big:
		ennemy.get_parent().throw()
	else:
		ennemy.get_parent().hit()