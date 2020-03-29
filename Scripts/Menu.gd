extends Control

func _ready():
	$TextureButton.connect("pressed",self,"_on_start_game")

func _on_start_game():
	$TextureButton/Label.text = "Loading..."
	$LoadingProgress.show()
	global.load_game()
