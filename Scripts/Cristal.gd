extends Spatial

export var limitVisible = 20

onready var player = get_tree().get_root().find_node("Elemental",true,false)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area.connect("area_entered",self,"recolt")
	pass # Replace with function body.

func _process(delta):
	if player!=null:
		if transform.origin.distance_to(player.transform.origin)>limitVisible:
			if !$aura.visible :
				$aura.visible = true
		else:
			if $aura.visible :
				$aura.visible = false

var isRecolted = false
func recolt(a):
	if isRecolted:
		return
	isRecolted = true
	$cristal.visible = false
	$Particles.emitting = true
	$Particles2.emitting = true
	var p = get_parent()
	if p is Cristals:
		p.addOne()
	$AudioStreamPlayer.play()
	yield(get_tree().create_timer(.95), "timeout")
	queue_free()

