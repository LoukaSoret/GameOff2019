extends Node

onready var root = get_tree().get_root()
onready var loading_progress = root.find_node("LoadingProgress",true,false)

var full_screen = true
var load_thread : Thread = Thread.new()
var loader : ResourceInteractiveLoader

func _ready():
	set_process(false)

func update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	# Update your progress bar?
	loading_progress.value = progress * 100

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
