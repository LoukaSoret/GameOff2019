extends KinematicBody

var path = []
var path_id = 0;
export var move_speed = 10
var nav : Navigation = null
var isRunning = false

func _ready():
	add_to_group("enemies")
	nav= get_tree().get_root().find_node("Navigation",true,false)
	if nav == null:
		push_error("Il faut un noeud nommé 'Navigation' de type Navigation dans l'arbre!")

func _physics_process(delta):
	if path_id < path.size():
		if(!isRunning):
			isRunning = true
			$Egg/AnimationPlayer.play("Run")
		var move_vec : Vector3 = (path[path_id]-global_transform.origin)
		if move_vec.length() < move_speed*delta:
			path_id += 1
		else:
			var angle = atan2(move_vec.x,move_vec.z)
			var r = get_rotation()
			r.y = angle
			set_rotation(r)
			#transform.rotated(Vector3(0,1,0),move_vec.angle_to(Vector3(0,0,1)))
			move_and_slide(move_vec.normalized()*move_speed,Vector3(0,1,0))
	else:
		if isRunning:
			isRunning = false
			$Egg/AnimationPlayer.play("Idle")

func move_to(target):
	path = nav.get_simple_path(global_transform.origin,target)
	path_id = 0