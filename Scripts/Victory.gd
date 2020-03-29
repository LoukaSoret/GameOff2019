extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	get_node("/root/Game").find_node("Cristals").connect("victory",self,"_on_victory")
	$TextureButton.connect("pressed",self,"_on_continue")
	$TextureButton2.connect("pressed",self,"_on_exit")

func _on_victory():
	show()
	get_tree().paused = true

func _on_continue():
	hide()
	get_tree().paused = false
	
func _on_exit():
	get_tree().quit()
