extends Control

@onready var mainScene = preload("res://scenes/main.tscn")
const DEFAULT_GAME_STATE := preload("res://resources/gameState/GameState1710.tres")



func _on_start_button_pressed() -> void:
	var scene_instance = mainScene.instantiate()

	scene_instance.gameState = DEFAULT_GAME_STATE

	var tree := get_tree()
	var old_scene := tree.current_scene

	tree.root.add_child(scene_instance)
	tree.current_scene = scene_instance

	old_scene.queue_free()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
