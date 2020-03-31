extends Area

func _ready():
	connect("area_entered",self,"_on_area_entered")

# the player hits a ennemis with a punch
func _on_area_entered(ennemy : Area):
	var dir = ennemy.to_global(Vector3(0,0,0))-get_parent().to_global(Vector3(0,0,0))
	ennemy.get_parent().take_damage(1,dir)
