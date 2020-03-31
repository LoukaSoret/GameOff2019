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
export var radiusPlayerDetection = 10.0

export var yKill = -30 #TODO!

onready var particle = preload("res://Ressources/particles/hit.tscn")
onready var player = get_tree().get_root().find_node("Elemental",true,false)

var hits : Array = []
var iHit = 0

func _ready():
	add_to_group("enemies")
	nav= get_tree().get_root().find_node("Navigation",true,false)
	if nav == null:
		push_error("Il faut un noeud nommé 'Navigation' de type Navigation dans l'arbre!")
	$attackbox/CollisionShape.scale = Vector3(0,0,0)
	hits.push_back($hits/hit)
	hits.push_back($hits/hit2)
	hits.push_back($hits/hit3)
	hits.push_back($hits/hit4)

var isKnockbacked = false
var knockback = Vector3()
var TIME_knockback = 0.5
var t_knockback = 0

var target = null
var delaySearchingPath = 0.2
var tSearchingPath = 0

var isAttacking = false
var tAttack = 0
var delayAttack = 0.5
var delayPreHitboxAttack = 0.3
var delayPostHitboxAttack = 1.0


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
	
	#path finding
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
			$Sounf_step.stop()
			
	
	#on floor test
	if !is_on_floor():
		movement.y += gravity
	else:
		movement.x = velocity.x
		movement.z = velocity.z
		movement.y = 0
		
	#knockback
	if isKnockbacked:
		movement = knockback.linear_interpolate(Vector3(),t_knockback/TIME_knockback)
		if t_knockback<TIME_knockback:
			isKnockbacked = false
		else:
			t_knockback += delta
		
		
	#search path if player is close
	if !isAttacking and tSearchingPath>delaySearchingPath and player != null and transform.origin.distance_to(player.transform.origin)< radiusPlayerDetection:
		target = player.transform.origin
		move_to(nav.get_closest_point(target))
		tSearchingPath = 0
	else:
		tSearchingPath += delta
	
	#attack if player is close
	if target!=null and transform.origin.distance_to(player.transform.origin)<2 and !isAttacking:
		path_id = path.size()
		isAttacking = true
		tAttack = 0
		$Egg/AnimationTree.set("parameters/attack/active",true)
	
	#end attack
	var triggered = false
	if isAttacking and tAttack>delayPreHitboxAttack:
		if !triggered:
			$attackbox/CollisionShape.scale = Vector3(1,1,1)
			triggered = true
		if tAttack>delayAttack:
			$attackbox/CollisionShape.scale = Vector3(0,0,0)
			if tAttack>delayPostHitboxAttack:
				isAttacking = false
				tAttack = 0
				triggered = false
	tAttack += delta
	
	#Y kill
	if transform.origin.y < yKill:
		print("free")
		queue_free()
	
	move_and_slide(movement,Vector3(0,1,0),false,4,deg2rad(90))

func setKnockback(v:Vector3,d=0.5):
	isKnockbacked = true
	TIME_knockback = d
	knockback = v
	t_knockback = 0

func move_to(target):
	path = nav.get_simple_path(global_transform.origin,target)
	path_id = 0


var pdv = maxPdv

func hit(dir : Vector2 = Vector2(0,0)):#TODO: vector direction en parametre
	pdv -= 1
	$Sound_hurt.play()
	$Egg/AnimationTree.set("parameters/hurt/active",true)
	hits[iHit%4].emitting = true
	hits[iHit%4].set_translation(get_parent().to_global(Vector3(0,2,0)))
	iHit += 1
	"""var p : Particles = particle.instance()
	add_child(p)
	p.set_translation(Vector3(0,2,0))
	p.activate()"""
	#setKnockback(-get_global_transform().basis.z.normalized()*knockbackForce)
	setKnockback(Vector3(dir.x,1,dir.y).normalized()*knockbackForce)
	
func throw(dir : Vector2 = Vector2(0,0)):#TODO: vector direction en parametre
	var d = $dustCircle
	d.emitting = true
	d.set_translation(get_parent().to_global(Vector3(0,0.5,0)))
	#var p : Particles = $hit
	hits[iHit%4].emitting = true
	hits[iHit%4].set_translation(get_parent().to_global(Vector3(0,2,0)))
	iHit += 1
	"""p.scale = scale
	get_parent().add_child(p)
	p.set_translation(get_parent().to_local(to_global(Vector3(0,2,0))))"""
	setKnockback(Vector3(dir.x,2,dir.y).normalized()*projectionForce,1)
	$Sound_hurt.play()
	$Egg/AnimationTree.set("parameters/hurt/active",true)
	isFlying = true
