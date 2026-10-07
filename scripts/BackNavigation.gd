extends Node

const MENU_SCENE := "res://scenes/menue.tscn"
const EVENT_SCENE := "res://scenes/main.tscn"
const EDIT_SCENE := "res://UI/GameStateSetup/GameStateSetup.tscn"


func _ready() -> void:
	if OS.get_name() == "Android":
		get_tree().set_auto_accept_quit(false)


func _notification(what: int) -> void:
	if what != NOTIFICATION_WM_GO_BACK_REQUEST:
		return
	_handle_back_request()


func _handle_back_request() -> void:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return

	if _close_open_dialog(current_scene):
		return

	var scene_path := current_scene.scene_file_path
	if scene_path == MENU_SCENE:
		return
	if scene_path == EVENT_SCENE or scene_path == EDIT_SCENE:
		get_tree().change_scene_to_file(MENU_SCENE)


func _close_open_dialog(current_scene: Node) -> bool:
	for dialog in current_scene.find_children("*", "Window", true, false):
		if dialog.visible:
			dialog.hide()
			return true
	return false
