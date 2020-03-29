extends Label

onready var game = get_node("/root/Game")
onready var player = game.find_node("Elemental")

func _ready():
	hide()
	get_tree().paused = false
	player.connect("player_die",self,"_on_player_die")
	$TextureButton.connect("pressed",self,"_on_retry_pressed")
	$TextureButton.connect("mouse_entered",self,"_on_retry_focus")
	$TextureButton.connect("mouse_exited",self,"_on_retry_unfocus")
	
func _on_player_die():
	show()
	get_tree().paused = true
	
func _on_retry_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/Tests/GameTvdd.tscn")

func _on_retry_unfocus():
	$TextureButton/Retry.add_color_override("font_color",Color("8cfff9"))

func _on_retry_focus():
	$TextureButton/Retry.add_color_override("font_color",Color("fbff8c"))
