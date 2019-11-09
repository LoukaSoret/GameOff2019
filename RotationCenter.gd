extends Spatial

export var x_rotation_limit : Vector2 = Vector2(-90,90) # (max,min) rotation allowed on the x axis
export var zoom_limit : Vector2 = Vector2(10,1) # (max,min) zoom allowed
export var zoom_step : float = 0.5
export var zoom_speed : float = 10

var rotating : bool = false
var moving : bool = false
var zooming : bool = false
var zoom_target : Vector3 = Vector3()
var last_position : Vector2 = Vector2()

func _ready():
	set_process(false)

func _input(event):
	if event.is_action("camera_rotate"):
		rotating = event.is_pressed()
		if rotating:
			last_position = event.position
	if event.is_action_pressed("camera_zoom_in"):
		var offset = $RotationHelper/Camera.transform.origin.direction_to($RotationHelper.transform.origin) * zoom_step
		zoom_target = $RotationHelper/Camera.transform.origin + offset
		if zoom_target.distance_to($RotationHelper.transform.origin) < zoom_limit.y:
			zoom_target = $RotationHelper.transform.origin.direction_to($RotationHelper/Camera.transform.origin)*zoom_limit.y
		set_process(true)
		zooming = true
	if event.is_action_pressed("camera_zoom_out"):
		var offset = $RotationHelper/Camera.transform.origin.direction_to($RotationHelper.transform.origin) * zoom_step
		zoom_target = $RotationHelper/Camera.transform.origin - offset
		if zoom_target.distance_to($RotationHelper.transform.origin) > zoom_limit.x:
			zoom_target = $RotationHelper.transform.origin.direction_to($RotationHelper/Camera.transform.origin)*zoom_limit.x
		set_process(true)
		zooming = true
	if event.is_action("camera_move"):
		moving = event.is_pressed()
		if moving:
			last_position = event.position
	if event is InputEventMouseMotion:
		if rotating:
			var delta = event.position - last_position
			last_position = event.position
			rotate_y(-delta.x * 0.01)
			#print($RotationHelper.rotation_degrees)
			if ($RotationHelper.rotation_degrees.x > x_rotation_limit.x or delta.y <= 0) and ($RotationHelper.rotation_degrees.x < x_rotation_limit.y or delta.y >= 0) :
				$RotationHelper.rotate_x(-delta.y * 0.01)
		elif moving:
			pass

func _process(delta):
	var interpol = $RotationHelper/Camera.transform.origin.linear_interpolate(zoom_target,zoom_speed*delta)
	if ($RotationHelper/Camera.transform.origin != zoom_target):
		$RotationHelper/Camera.transform.origin=interpol
	else:
		zooming = false
		set_process(false)