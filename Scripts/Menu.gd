extends Control

func _ready():
	$TextureButton.connect("pressed",self,"_on_start_game")

func _on_start_game():
	$TextureButton/Label.text = "Loading...\nThe program will stop responding,\nthat's normal, the game is loading anyway.\nThe game takes some time to load don't be afraid."
	yield(get_tree().create_timer(0.5),"timeout")
	get_tree().change_scene("res://Scenes/Tests/GameTvdd.tscn")