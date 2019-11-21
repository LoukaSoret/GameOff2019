extends KinematicBody

var path = []
var path_id = 0;
export var move_speed = 10
var nav : Navigation = null
var isRunning = false
var isFlying = false

export var gravity = -5
export var knockbackForce = 10.0
export var projectionForce = 10.0
export var maxPdv = 3

export var yKill = 0 #TODO!

onready var particle = preload("res://Ressources/particles/hit.tscn")
onready var dust = preload("res://Ressources/particles/dustCircle.tscn")

func _ready():
	add_to_group("enemies")
	nav= get_tree().get_root().find_node("Navigation",true,false)
	if nav == null:
		push_error("Il faut un noeud nommé 'Navigation' de type Navigation dans l'arbre!")

var isKnockbacked = false
var knockback = Vector3()
var TIME_knockback = 0.5
var t_knockback = 0

var movement = Vector3()
func _physics_process(delta):
	var velocity = Vector3()
	
	#anim dust
	if isRunning or isFlying:
		$dustTrail.emitting = true
	else:
		$dustTrail.emitting = false
	if isFlying and is_on_floor() and movement.y<-10: #TODO: améliorer
		isFlying = false
	
	if path_id < path.size():
		if(!isRunning):
			isRunning = true
			$Egg/AnimationTree.set("parameters/idle_run/blend_amount",1)
		var move_vec : Vector3 = (path[path_id]-global_transform.origin)
		if move_vec.length() < move_speed*delta*10:
			path_id += 1
		else:
			var angle = atan2(move_vec.x,move_vec.z)
			var r = get_rotation()
			r.y = angle
			set_rotation(r)
			#transform.rotated(Vector3(0,1,0),move_vec.angle_to(Vector3(0,0,1)))
			velocity = move_vec.normalized()*move_speed
	else:
		if isRunning:
			isRunning = false
			$Egg/AnimationTree.set("parameters/idle_run/blend_amount",0)
			
	
	if !is_on_floor():
		movement.y += gravity
	else:
		movement.x = velocity.x
		movement.z = velocity.z
		movement.y = 0
		
	if (Input.is_action_just_pressed("ui_select")):
		movement.y = 100
		
	if isKnockbacked:
		movement += knockback.linear_interpolate(Vector3(),t_knockback/TIME_knockback)
		if t_knockback<TIME_knockback:
			isKnockbacked = false
		else:
			t_knockback += delta
		
	
	move_and_slide(movement,Vector3(0,1,0))


func setKnockback(v,d=0.5):
	isKnockbacked = true
	TIME_knockback = d
	knockback = v
	t_knockback = 0

func move_to(target):
	path = nav.get_simple_path(global_transform.origin,target)
	path_id = 0


var pdv = maxPdv

func hurt():#TODO: vector direction en parametre
	pdv -= 1
	if pdv<=0:
		project()
	else:
		$Egg/AnimationTree.set("parameters/hurt/active",true)
		var p : Particles = particle.instance()
		add_child(p)
		p.set_translation(Vector3(0,2,0))
		setKnockback(-get_global_transform().basis.z.normalized()*knockbackForce)
	
func project():#TODO: vector direction en parametre
	var d = dust.instance()
	d.scale = scale
	get_parent().add_child(d)
	d.set_translation(get_parent().to_local(to_global(Vector3(0,0.5,0))))
	var p : Particles = particle.instance()
	p.scale = scale
	get_parent().add_child(p)
	p.set_translation(get_parent().to_local(to_global(Vector3(0,2,0))))
	var v : Vector3 = -get_global_transform().basis.z.normalized()
	v.y = 2
	setKnockback(v*projectionForce,1)
	isFlying = true