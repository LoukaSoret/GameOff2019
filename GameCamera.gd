extends Spatial

class_name GameCamera, "res://Ressources/icons/GameCamera.png"

enum View_mode {
	SHOULDER,
	HACK_N_SLASH
}

export var target_node : String
export (View_mode) var mode = View_mode.HACK_N_SLASH
export var smoothing : float = 1.0
export var anchor_shoulder_position : Vector3
export var anchor_shoulder_rotation : Vector3

var target : Spatial
var anchor : Vector3
var anchor_rotation : Vector3
var mouse_sens = 0.3
var last_mode
var next_pos = Vector3()
var next_angle = Vector3()

func _ready():
	target = get_parent().find_node(target_node)
	anchor = $Camera.transform.origin - target.transform.origin
	anchor_rotation = $Camera.rotation
	last_mode = mode
	next_pos = anchor
	next_angle = anchor_rotation

func _physics_process(delta):
	if Input.is_action_just_released("ui_accept"):
		mode = (mode + 1) % 2
	match mode:
		View_mode.HACK_N_SLASH:
			self.rotation = self.rotation.linear_interpolate(Vector3(), delta*smoothing)
			if last_mode == View_mode.SHOULDER:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				last_mode = View_mode.HACK_N_SLASH
				next_angle = anchor_rotation
				next_pos = anchor
		View_mode.SHOULDER:
			self.rotation = self.rotation.linear_interpolate(target.rotation, delta*smoothing)
			if last_mode == View_mode.HACK_N_SLASH:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				last_mode = View_mode.SHOULDER
				next_angle = anchor_shoulder_rotation
				next_pos = anchor_shoulder_position
	self.transform.origin = self.transform.origin.linear_interpolate(target.transform.origin, delta*smoothing)
	$Camera.transform.origin = $Camera.transform.origin.linear_interpolate(next_pos, delta*smoothing)
	$Camera.rotation = $Camera.rotation.linear_interpolate(next_angle, delta*smoothing)

func _input(event):    
	if mode == View_mode.SHOULDER:
		if event is InputEventMouseMotion:
			print_debug("GROS EVENT")
			self.rotate_y(deg2rad(-event.relative.x*mouse_sens))