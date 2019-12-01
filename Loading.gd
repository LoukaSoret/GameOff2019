extends Spatial

# based on http://docs.godotengine.org/en/3.1/tutorials/io/background_loading.html

var scenePath = "res://Scenes/Tests/GameTvdd.tscn"
var queue

var resource
var instance 
var instanceIsLoading = false
var instanceIsReady = false

func _ready() -> void:
	# Initialize.
	queue = preload("res://Scripts/resource_queue.gd").new()
	queue.start()
	queue.queue_resource(scenePath, true)
	pass # Replace with function body.


func _process(delta: float) -> void:
	if !instanceIsLoading:
		if queue.is_ready(scenePath):
				resource = queue.get_resource(scenePath)
				start()
				instanceIsLoading = true
		else:
			#var p = queue.get_progress(scenePath)
			pass
	else:
		if instanceIsReady:
			set_new_scene()
	pass

func set_new_scene():
	#https://godotengine.org/qa/24773/how-to-load-and-change-scenes
	var root = get_tree().get_root()
	
	var level = root.get_node("Loading")
	root.remove_child(level)
	level.call_deferred("free")
	
	# Add the next level
	root.add_child(instance)
	
	

	
var thread
var mutex
	
func thread_func(u):
	mutex.lock()

	instance = resource.instance()
	instanceIsReady = true

	mutex.unlock()

func start():
	mutex = Mutex.new()
	thread = Thread.new()
	thread.start(self, "thread_func", 0)