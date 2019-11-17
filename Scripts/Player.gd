extends KinematicBody

onready var game = get_node("/root/Game")
onready var camera = game.find_node("Camera")
onready var game_camera = game.find_node("GameCamera")
onready var animationStateMachine = $AnimationTree.get("parameters/playback")

export var max_speed : float = 100 # unit/second
export var acceleration : float = 200 # unit/second²
export var deceleration : float = 200 # unit/second²
export var gravity_acceleration : float = 980 # unit/second²

var velocity : Vector3 = Vector3() # unit/second
var gravity : float # unit/second

var bigFeetPosition : Vector3
var mediumFeetPosition : Vector3
var smallFeetPosition : Vector3

var puncharm : int = 0

func _ready():
	animationStateMachine.start("Idle")
	bigFeetPosition = $Mesh/Feets/FeetBig.transform.origin
	mediumFeetPosition = $Mesh/Feets/FeetMedium.transform.origin
	smallFeetPosition = $Mesh/Feets/RotationHelperSmallFeet.transform.origin

func _physics_process(delta):
	var angle = Vector3()
	var movement : float = 0
	var tmp
	var acceleration_direction : Vector3 = Vector3.ZERO # unit/second²
	
	############
	# MOVEMENT #
	############
	if Input.is_action_pressed("move_left"):
		if game_camera.mode == GameCamera.View_mode.HACK_N_SLASH:
			acceleration_direction -= camera.get_global_transform().basis.x
		movement = 1
	elif Input.is_action_pressed("move_right"):
		if game_camera.mode == GameCamera.View_mode.HACK_N_SLASH:
			acceleration_direction += camera.get_global_transform().basis.x
		movement = 1
	if Input.is_action_pressed("move_up"):
		if game_camera.mode == GameCamera.View_mode.HACK_N_SLASH:
			acceleration_direction -= camera.get_global_transform().basis.z
		movement = 1
	elif Input.is_action_pressed("move_down"):
		if game_camera.mode == GameCamera.View_mode.HACK_N_SLASH:
			acceleration_direction += camera.get_global_transform().basis.z
			movement = 1
		elif game_camera.mode == GameCamera.View_mode.SHOULDER:
			movement = -1
	acceleration_direction.y = 0
	acceleration_direction = acceleration_direction.normalized()
	# Deccelerate
	if velocity.length() > 0: # deccelerate only if velocity is not null
		var vel_before_decel : Vector3 = velocity
		# We don't want to deccelerate on the direction we're accelerating
		velocity -= deceleration*(velocity.normalized()-acceleration_direction).normalized()*delta
		if sign(vel_before_decel.x) != sign(velocity.x):
			velocity.x = 0
		if sign(vel_before_decel.z) != sign(velocity.z):
			velocity.z = 0
	# Accelerate
	velocity += acceleration*acceleration_direction*delta
	# Clamp to max_speed
	velocity = velocity if velocity.length() <= max_speed else velocity.normalized()*max_speed
	# Apply gravity
	gravity = 0 if is_on_floor() else gravity-gravity_acceleration*delta
	velocity.y = gravity
	move_and_slide(velocity*delta,Vector3.UP,false,4,deg2rad(90))

	#Les pieds de ses morts
	var dir : Vector3
	var velocity2D : Vector3 = Vector3(velocity.normalized().x,0,velocity.normalized().z)
	if(transform.basis.z.angle_to(Vector3.LEFT) > transform.basis.z.angle_to(Vector3.RIGHT)):
		dir = velocity2D.rotated(Vector3.UP,Vector3.FORWARD.angle_to(transform.basis.z))
	else:
		dir = velocity2D.rotated(Vector3.UP,-Vector3.FORWARD.angle_to(transform.basis.z))
	$Mesh/Feets/FeetBig.transform.origin = lerp(bigFeetPosition,bigFeetPosition + dir*0.5,velocity.length()/max_speed)
	$Mesh/Feets/FeetMedium.transform.origin = lerp(mediumFeetPosition,mediumFeetPosition + dir*1.5,velocity.length()/max_speed)
	$Mesh/Feets/RotationHelperSmallFeet.transform.origin = lerp(smallFeetPosition,smallFeetPosition + dir*1.25,velocity.length()/max_speed)
	$Mesh/Feets/FeetBig.rotate(transform.basis.y.normalized(),deg2rad(180)*delta/2)
	$Mesh/Feets/FeetMedium.rotate(transform.basis.y.normalized(),deg2rad(180)*delta)
	$Mesh/Feets/RotationHelperSmallFeet.rotate(transform.basis.y.normalized(),-deg2rad(180)*delta)
	
	###############
	# ORIENTATION #
	###############
	#if game_camera.mode == GameCamera.View_mode.SHOULDER:
	#	self.rotation = game_camera.rotation
	
	if game_camera.mode == GameCamera.View_mode.HACK_N_SLASH:
		var from : Vector3 = camera.project_ray_origin(get_viewport().get_mouse_position())
		var normal : Vector3 = camera.project_ray_normal(get_viewport().get_mouse_position())
		# We want the resuting vector to be the same distance in y as the vector between the camera
		# and the character (i.e. on the same plane)
		var to = Plane(transform.origin,transform.origin+transform.basis.x,transform.origin+transform.basis.z).intersects_ray(from,normal)
		if to != null:
			tmp = scale
			var rot = transform.basis.z.angle_to(to - transform.origin) + deg2rad(180)
			if((to - transform.origin).angle_to(transform.basis.x) > (to - transform.origin).angle_to(-transform.basis.x)):
				rotate(transform.basis.y.normalized(),-rot)
			else :
				rotate(transform.basis.y.normalized(),rot)
			scale = tmp
		
	
func _input(event):
	if Input.is_action_just_released("ui_accept"):
		if game_camera.mode == GameCamera.View_mode.HACK_N_SLASH:
			animationStateMachine.travel("TransformIn")
		else:
			animationStateMachine.travel("Idle")
	elif Input.is_action_pressed("attack") and game_camera.mode == GameCamera.View_mode.HACK_N_SLASH:
		if puncharm == 0:
			animationStateMachine.travel("PunchLeft")
			puncharm = (puncharm+1)%2
		else:
			animationStateMachine.travel("PunchRight")
			puncharm = (puncharm+1)%2
	else:
		animationStateMachine.travel("Idle")