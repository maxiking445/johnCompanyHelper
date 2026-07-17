extends Control

signal upload_gamestate(loaded_game_state: GameState)
signal download_gamestate(downloaded_game_state: GameState)

const DEFAULT_DOWNLOAD_FILE_NAME := "game_state.json"

@export var game_state: GameState

@onready var _upload_dialog: FileDialog = $UploadDialog
@onready var _download_dialog: FileDialog = $DownloadDialog


func _ready() -> void:
	pass

func _on_upload_button_pressed() -> void:
	_upload_dialog.popup_file_dialog()


func _on_download_button_pressed() -> void:
	if game_state == null:
		push_error("No current GameState is available for download.")
		return
	_download_dialog.current_file = DEFAULT_DOWNLOAD_FILE_NAME
	_download_dialog.popup_file_dialog()


func _on_download_dialog_file_selected(path: String) -> void:
	if game_state == null:
		push_error("No current GameState is available for download.")
		return

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error(
			"Could not write GameState JSON to %s (error %s)."
			% [path, FileAccess.get_open_error()]
		)
		return

	file.store_string(JSONConverter.stringify(game_state))
	file.close()
	download_gamestate.emit(game_state)
	


func _on_upload_dialog_file_selected(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error(
			"Could not read GameState JSON from %s (error %s)."
			% [path, FileAccess.get_open_error()]
		)
		return

	var json := file.get_as_text()
	file.close()
	var loaded_game_state := JSONConverter.parse(json, GameState) as GameState
	if loaded_game_state == null:
		push_error("The selected JSON does not contain a valid GameState.")
		return

	upload_gamestate.emit(loaded_game_state)
