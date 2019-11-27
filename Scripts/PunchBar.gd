extends TextureProgress

onready var timer : Timer = $Timer

export var amplitude : = 6.0
export var shake : = false setget set_shake

var enabled : = false


func _ready() -> void:
	randomize()
	set_process(false)


func _process(delta: float) -> void:
	rect_position = Vector2(
		rand_range(amplitude, -amplitude),
		rand_range(amplitude, -amplitude))

func set_shake(value: bool) -> void:
	shake = value
	set_process(shake)
	rect_position = Vector2()