extends Control

func _ready():
	$TextureButton.connect("pressed",self,"_on_start_game")

func _on_start_game():
	$TextureButton/Label.text = "Loading..."
	yield(get_tree().create_timer(0.5),"timeout")
	global.load_game()
