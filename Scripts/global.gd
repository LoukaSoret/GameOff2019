extends Node

onready var root = get_tree().get_root()
onready var loading_progress = root.find_node("LoadingProgress",true,false)

var full_screen = false
var load_thread : Thread = Thread.new()
var loader : ResourceInteractiveLoader

func _ready():
	#get_viewport().set_size_override(true,Vector2(1920,1080))
	#OS.set_window_size(Vector2(1280,720))
	#OS.window_fullscreen = false
	set_process(false)

func update_progress():
	var progress = float(loader.get_stage()*100) / loader.get_stage_count()
	# Update your progress bar?
	loading_progress.value = progress

func load_game():
	load_thread.start(self,"load_thread_func")

func load_thread_func(userdata):
	loader = ResourceLoader.load_interactive("res://Scenes/Game.tscn")
	if loader == null: # check for errors
		print("Error: could not create loader.")
		return
	var err = loader.poll()
	while err != ERR_FILE_EOF: # Finished loading.
		if err == OK:
			update_progress()
		else: # error during loading
			print("Error during loading.")
			loader = null
			return
		err = loader.poll()
	
	var resource = loader.get_resource()
	loader = null
	get_tree().change_scene_to(resource)

"""
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if global.full_screen == false:
			OS.window_fullscreen = true
			global.full_screen = true
		else :
			OS.window_fullscreen = false
			global.full_screen = false
"""
