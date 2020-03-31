extends Spatial

class_name GameCamera, "res://Ressources/icons/GameCamera.png"

enum View_mode {
	SHOULDER,
	HACK_N_SLASH
}

export(NodePath) var target_node
export (View_mode) var mode = View_mode.HACK_N_SLASH
export var smoothing : float = 1.0
export var anchor_shoulder_position : Vector3
export var anchor_shoulder_rotation : Vector3

var target : Spatial
var anchor : Vector3 = Vector3()
var anchor_rotation : Vector3 = Vector3()
#var mouse_sens = 0.3
var last_mode
var next_pos : Vector3 = Vector3()
var next_angle : Vector3 = Vector3()

var hack_rotation : Vector3 = Vector3()

func _ready():
	target = get_node(target_node)
	#anchor = to_global($Camera.transform.origin) - to_global(target.transform.origin)
	global_transform.origin = target.global_transform.origin
	anchor = $Camera.global_transform.origin - target.global_transform.origin
	anchor_rotation = $Camera.rotation
	last_mode = mode
	next_pos = anchor
	next_angle = anchor_rotation
	hack_rotation = self.rotation

func _physics_process(delta):
	if Input.is_action_just_released("ui_accept") and get_node("/root/Game").find_node("Elemental").state != "Hurt" and get_node("/root/Game").find_node("Elemental").state != "Punching":
		mode = (mode + 1) % 2
		match mode:
			View_mode.HACK_N_SLASH:
				self.rotation = self.rotation.linear_interpolate(Vector3(), delta*smoothing)
				if last_mode == View_mode.SHOULDER:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					last_mode = View_mode.HACK_N_SLASH
					next_angle = anchor_rotation
					next_pos = anchor
					hack_rotation = Vector3(0,rotation.y,0)
			View_mode.SHOULDER:
				#self.rotation = self.rotation.linear_interpolate(target.rotation, delta*smoothing)
				if last_mode == View_mode.HACK_N_SLASH:
					#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					last_mode = View_mode.SHOULDER
					next_angle = anchor_shoulder_rotation
					next_pos = anchor_shoulder_position
	self.transform.origin = self.transform.origin.linear_interpolate(target.transform.origin, delta*smoothing)
	$Camera.transform.origin = $Camera.transform.origin.linear_interpolate(next_pos, delta*smoothing)
	
	if mode == View_mode.SHOULDER:
		var lookDir = target.transform.origin + target.transform.basis.z
		var rotTransform = transform.looking_at(lookDir,Vector3(0,1,0))
		var thisRotation = Quat(transform.basis.orthonormalized()).slerp(rotTransform.basis.orthonormalized(),delta*smoothing*2)
		set_transform(Transform(thisRotation,transform.origin))
	else:
		self.rotation = self.rotation.linear_interpolate(hack_rotation, delta*smoothing)
	$Camera.rotation = $Camera.rotation.linear_interpolate(next_angle, delta*smoothing)
	
	var tmp = scale
	transform.basis = transform.basis.orthonormalized()
	transform.basis = transform.basis.scaled(tmp)
