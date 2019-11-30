extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$TextureButton.connect("pressed",self,"_on_start_game")

func _on_start_game():
	$TextureButton/Label.text = "Loading..."
	yield(get_tree().create_timer(0.5),"timeout")
	get_tree().change_scene("res://Scenes/Tests/GameTvdd.tscn")