extends Node

var full_screen = true

var load_thread : Thread = Thread.new()

func load_game():
	load_thread.start(self,"load_thread_func")

func load_thread_func(userdata):
	var game = load("res://Scenes/Game.tscn")
	get_tree().change_scene_to(game)
