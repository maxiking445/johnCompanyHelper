extends Node
class_name GameStateJsonTransfer

signal import_completed(game_state: GameState, source_path: String)
signal export_completed(target_path: String)
signal transfer_failed(message: String)

const DEFAULT_FILE_NAME := "game_state.json"

@onready var import_dialog: FileDialog = $ImportDialog
@onready var export_dialog: FileDialog = $ExportDialog

var game_state_to_export: GameState


func show_import_dialog() -> void:
	import_dialog.popup_file_dialog()


func show_export_dialog(game_state: GameState) -> void:
	if game_state == null:
		transfer_failed.emit("No current GameState is available for export.")
		return
	game_state_to_export = game_state
	export_dialog.current_file = DEFAULT_FILE_NAME
	export_dialog.popup_file_dialog()


func _on_export_dialog_file_selected(path: String) -> void:
	if game_state_to_export == null:
		transfer_failed.emit("No current GameState is available for export.")
		return
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		transfer_failed.emit(
			"Could not write GameState JSON to %s (error %s)."
			% [path, FileAccess.get_open_error()]
		)
		return
	file.store_string(JSONConverter.stringify(game_state_to_export))
	file.close()
	export_completed.emit(path)


func _on_import_dialog_file_selected(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		transfer_failed.emit(
			"Could not read GameState JSON from %s (error %s)."
			% [path, FileAccess.get_open_error()]
		)
		return
	var json := file.get_as_text()
	file.close()
	var loaded_game_state := JSONConverter.parse(json, GameState) as GameState
	if loaded_game_state == null:
		transfer_failed.emit(
			"The selected JSON does not contain a valid GameState."
		)
		return
	import_completed.emit(loaded_game_state, path)
