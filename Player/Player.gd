extends KinematicBody

export var speed : float = 5.0
export var acceleration : float = 10

var velocity = Vector3()
var camera
var game_camera

func _ready():
	camera = get_parent().find_node("Camera").get_global_transform()
	game_camera = get_parent().find_node("GameCamera")

func _physics_process(delta):
	var angle = Vector3()
	var movement : float = 0
	if game_camera.mode == GameCamera.View_mode.SHOULDER:
		self.rotation = game_camera.rotation
	if Input.is_action_pressed("move_left"):
		if game_camera.mode == GameCamera.View_mode.HACK_N_SLASH:
			angle += -camera.basis[0]
		movement = 1
	if Input.is_action_pressed("move_right"):
		if game_camera.mode == GameCamera.View_mode.HACK_N_SLASH:
			angle += camera.basis[0]
		movement = 1
	if Input.is_action_pressed("move_up"):
		if game_camera.mode == GameCamera.View_mode.HACK_N_SLASH:
			angle += -camera.basis[2]
		movement = 1
	if Input.is_action_pressed("move_down"):
		if game_camera.mode == GameCamera.View_mode.HACK_N_SLASH:
			angle += camera.basis[2]
			movement = 1
		elif game_camera.mode == GameCamera.View_mode.SHOULDER:
			movement = -1
	angle.y = 0
	#if game_camera.mode == GameCamera.View_mode.HACK_N_SLASH:
	self.look_at(self.transform.origin+angle, Vector3(0, 1, 0))
	#self.move_and_collide(movement)
	translate(delta*speed*movement*Vector3.FORWARD)