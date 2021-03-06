extends Area

signal setPunchVar(i)

var punch_big : bool = false

func _ready():
	connect("area_entered",self,"_on_area_entered")

# the player hits a ennemis with a punch
func _on_area_entered(ennemy : Area):
	var dir = ennemy.to_global(Vector3(0,0,0))-get_parent().to_global(Vector3(0,0,0))
	if punch_big:
		ennemy.get_parent().throw(Vector2(dir.x,dir.z).normalized())
	else:
		get_parent().bigPunchVar = get_parent().bigPunchVar+1 if get_parent().bigPunchVar < get_parent().bigPunchThreshold else get_parent().bigPunchVar
		ennemy.get_parent().hit(Vector2(dir.x,dir.z).normalized())
	get_parent().get_node("PunchBarRender/PunchBar").value = get_parent().bigPunchVar
	if get_parent().bigPunchVar >= get_parent().bigPunchThreshold and not punch_big:
		get_parent().get_node("PunchBarRender/PunchBar").tint_progress = Color("e83030")
		get_parent().get_node("PunchBarRender/PunchBar").set_shake(true)
		get_parent().get_node("HUD/Clic").visible = true
	elif punch_big:
		get_parent().bigPunchVar = 0
		get_parent().get_node("PunchBarRender/PunchBar").tint_progress = Color("ffffff")
		get_parent().get_node("PunchBarRender/PunchBar").set_shake(false)
		get_parent().get_node("HUD/Clic").visible = false
