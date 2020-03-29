extends TextureProgress

export(NodePath) var target_path

onready var target = get_node(target_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	max_value = target.max_life
	value = target.current_life
	$Label.set_text(str(value)+"/"+str(max_value))
	target.connect("life_update",self,"_on_life_update")

func _on_life_update():
	value = target.current_life
	$Label.set_text(str(value)+"/"+str(max_value))
