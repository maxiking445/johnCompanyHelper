extends Control

const MAIN_SCENE := preload("res://scenes/main.tscn")
const SETUP_SCENE := preload("res://UI/GameStateSetup/GameStateSetup.tscn")

@onready var continue_button: Button = %ContinueButton


func _ready() -> void:
	continue_button.disabled = not _save_manager().has_progress()


func _on_start_button_pressed() -> void:
	_open_game(_save_manager().reset_to_default(), 0)


func _on_continue_button_pressed() -> void:
	if not _save_manager().has_progress():
		return
	_open_game(_save_manager().load_current(), 1)


func _on_edit_save_button_pressed() -> void:
	_replace_scene(SETUP_SCENE.instantiate())


func _open_game(game_state: GameState, launch_mode: int) -> void:
	var scene_instance := MAIN_SCENE.instantiate()
	scene_instance.gameState = game_state
	scene_instance.launch_mode = launch_mode
	_replace_scene(scene_instance)


func _replace_scene(scene_instance: Node) -> void:
	var tree := get_tree()
	var old_scene := tree.current_scene
	tree.root.add_child(scene_instance)
	tree.current_scene = scene_instance
	if old_scene != null:
		old_scene.queue_free()


func _save_manager() -> Node:
	return get_node("/root/SaveGameManager")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
