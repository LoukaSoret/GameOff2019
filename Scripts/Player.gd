extends KinematicBody

signal life_update()
signal player_die()

onready var game = get_node("/root/Game")
onready var camera = game.find_node("Camera")
onready var game_camera = game.find_node("GameCamera")
onready var animationStateMachine = $AnimationTree.get("parameters/playback")

# Hack'n'slash movement vars
export var max_speed : float = 200 # unit/second
export var acceleration : float = 400 # unit/second²
export var deceleration : float = 400 # unit/second²
export var gravity_acceleration : float = 980 # unit/second²
export var knockback_speed : float = 700 # unit/second²
export var deadly_gravity : float = -1300
var gravity : float # unit/second

# Flight movement vars
export var flight_max_speed : float = 300 # unit/second

# General movement var
var velocity : Vector3 = Vector3() # unit/second

# Initial positions of the feets, for animation.
var bigFeetPosition : Vector3
var mediumFeetPosition : Vector3
var smallFeetPosition : Vector3

#Life vars
export var max_life : int = 3
var current_life : int = 3

# Attack vars
var punch_timer : float = 2
var punch_delay : Dictionary = {"Punch" : 0.5, "PunchBig": 2}
var punch_monitor_threshold : Dictionary = {"Punch" : 0.14, "PunchBig": 0.4}
var punch_unmonitor_threshold : Dictionary = {"Punch" : 0.3, "PunchBig": 1.3}
var current_punch : String = "Punch"
var puncharm : int = 0
var hold_input_timer : float = 0.6
var hold_input_delay : float = 0.6
var bigPunchVar : int = 0
export var bigPunchThreshold : int = 5

#State var
var state : String = ""

func _ready():
	animationStateMachine.start("Idle")
	bigFeetPosition = $Mesh/Feets/FeetBig.transform.origin
	mediumFeetPosition = $Mesh/Feets/FeetMedium.transform.origin
	smallFeetPosition = $Mesh/Feets/RotationHelperSmallFeet.transform.origin

func _physics_process(delta):
	var tmp
	var acceleration_direction : Vector3 = Vector3.ZERO # unit/second²
	
	#########################
	# HACK'N'SLASH MOVEMENT #
	#########################
	
	if game_camera.mode == GameCamera.View_mode.HACK_N_SLASH:
		if hold_input_timer < hold_input_delay:
			hold_input_timer += delta
		else:
			if Input.is_action_pressed("move_left"):
					acceleration_direction -= camera.get_global_transform().basis.x
			elif Input.is_action_pressed("move_right"):
					acceleration_direction += camera.get_global_transform().basis.x
			if Input.is_action_pressed("move_up"):
					acceleration_direction -= camera.get_global_transform().basis.z
			elif Input.is_action_pressed("move_down"):
					acceleration_direction += camera.get_global_transform().basis.z
			acceleration_direction.y = 0
			acceleration_direction = acceleration_direction.normalized()
		# Deccelerate
		if velocity.length() > 0 or hold_input_timer >= hold_input_delay: # deccelerate only if velocity is not null
			var vel_before_decel : Vector3 = velocity
			# We don't want to deccelerate on the direction we're accelerating
			velocity -= deceleration*(velocity.normalized()-acceleration_direction).normalized()*delta
			# Clamp to 0
			velocity.x = 0 if sign(vel_before_decel.x) != sign(velocity.x) else velocity.x
			velocity.z = 0 if sign(vel_before_decel.z) != sign(velocity.z) else velocity.z
		# Accelerate
		velocity += acceleration*acceleration_direction*delta
		# Clamp to max_speed
		if hold_input_timer >= hold_input_delay:
			velocity = velocity if velocity.length() <= max_speed else velocity.normalized()*max_speed
		# Apply gravity
		gravity = 0 if is_on_floor() else gravity-gravity_acceleration*delta
		if gravity <= deadly_gravity:
			current_life = 0
			emit_signal("player_die")
		velocity.y = gravity
		move_and_slide(velocity*delta,Vector3.UP,false,4,deg2rad(90))
	
	###################
	# FLIGHT MOVEMENT #
	###################
	elif game_camera.mode == GameCamera.View_mode.SHOULDER:
		velocity = -transform.basis.z.normalized() * flight_max_speed
		move_and_slide(velocity*delta,Vector3.UP,false,4,deg2rad(90))
		
	#############
	# ANIMATION #
	#############
	#Delayed feet
	if game_camera.mode == GameCamera.View_mode.HACK_N_SLASH:
		var dir : Vector3
		var velocity2D : Vector3 = Vector3(velocity.normalized().x,0,velocity.normalized().z)
		if(transform.basis.z.angle_to(Vector3.LEFT) > transform.basis.z.angle_to(Vector3.RIGHT)):
			dir = velocity2D.rotated(Vector3.UP,Vector3.FORWARD.angle_to(transform.basis.z))
		else:
			dir = velocity2D.rotated(Vector3.UP,-Vector3.FORWARD.angle_to(transform.basis.z))
		$Mesh/Feets/FeetBig.transform.origin = lerp(bigFeetPosition,bigFeetPosition + dir*0.5,velocity.length()/max_speed)
		$Mesh/Feets/FeetMedium.transform.origin = lerp(mediumFeetPosition,mediumFeetPosition + dir*1.5,velocity.length()/max_speed)
		$Mesh/Feets/RotationHelperSmallFeet.transform.origin = lerp(smallFeetPosition,smallFeetPosition + dir*1.25,velocity.length()/max_speed)
		$Mesh/Feets/FeetBig.rotate_object_local(Vector3.UP.normalized(),deg2rad(180)*delta/2)
		$Mesh/Feets/FeetMedium.rotate_object_local(Vector3.UP.normalized(),deg2rad(180)*delta)
		$Mesh/Feets/RotationHelperSmallFeet.rotate_object_local(Vector3.UP.normalized(),-deg2rad(180)*delta)
	
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
			look_at(to,Vector3.UP)
			transform.basis.y = Vector3.UP
			scale = tmp
	elif game_camera.mode == GameCamera.View_mode.SHOULDER :
		var from : Vector3 = camera.project_ray_origin(get_viewport().get_mouse_position())
		var normal : Vector3 = camera.project_ray_normal(get_viewport().get_mouse_position())
		var to : Vector3 = from + normal * 99999
		tmp = scale
		look_at(to,Vector3.UP)
		scale = tmp
	
	##########
	# COMBAT #
	##########
	if punch_timer < punch_delay[current_punch]:
		punch_timer += delta
	if punch_timer >= punch_unmonitor_threshold[current_punch]:
		$PunchHitBox.scale = Vector3(0,0,0)
	elif punch_timer >= punch_monitor_threshold[current_punch]:
		$PunchHitBox.scale = Vector3(1,1,1)
	
	if animationStateMachine.get_current_node() == "Idle":
		state = ""
	elif animationStateMachine.get_current_node() == "PunchBig" or animationStateMachine.get_current_node() == "PunchLeft" or animationStateMachine.get_current_node() == "PunchRight":
		state = "Punching"
	
	# Change view mode
	if Input.is_action_pressed("ui_accept") and state != "Hurt" and state != "Punching":
		if game_camera.mode == GameCamera.View_mode.HACK_N_SLASH:
			state = "Flying"
			$PunchBar.hide()
			animationStateMachine.travel("TransformIn")
			$HUD/Clic.hide()
		else:
			state = "Flying"
			$PunchBar.show()
			animationStateMachine.travel("TransformOut")
			if bigPunchVar >= bigPunchThreshold:
				$HUD/Clic.show()
	
	if game_camera.mode == GameCamera.View_mode.HACK_N_SLASH and state != "Flying":
		if punch_timer >= punch_delay[current_punch]:
			if Input.is_action_pressed("attack"):
				var animation : String = "PunchLeft" if puncharm == 0 else "PunchRight"
				$PunchHitBox.punch_big = false
				state = "Punching"
				animationStateMachine.travel(animation)
				puncharm = (puncharm+1)%2
				current_punch = "Punch"
				punch_timer = 0
			elif Input.is_action_pressed("bigattack") and bigPunchVar >= bigPunchThreshold:
					$PunchHitBox.punch_big = true
					bigPunchVar = 0
					$PunchBarRender/PunchBar.value = bigPunchVar
					$HUD/Clic.hide()
					state = "Punching"
					animationStateMachine.travel("PunchBig")
					current_punch = "PunchBig"
					punch_timer = 0
	
	tmp = scale
	transform.basis = transform.basis.orthonormalized()
	transform.basis = transform.basis.scaled(tmp)

func take_damage(damage : int, collision_normal : Vector3):
	if hold_input_timer >= hold_input_delay:
		if state != "Flying":
			state = "Hurt"
			current_life -= damage
			clamp(current_life,0,max_life)
			emit_signal("life_update")
			animationStateMachine.start("Hurt")
			velocity = knockback_speed*collision_normal.normalized()
			hold_input_timer = 0
			if current_life <= 0:
				yield(get_tree().create_timer(0.6),"timeout")
				emit_signal("player_die")