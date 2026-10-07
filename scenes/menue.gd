extends Control

const MAIN_SCENE := preload("res://scenes/main.tscn")
const SETUP_SCENE := preload("res://UI/GameStateSetup/GameStateSetup.tscn")
const CONFIRMATION_DIALOG_SCENE := preload("res://scenes/component/dialog/confirmation_dialog.tscn")

@onready var continue_button: Button = %ContinueButton
@onready var menu_buttons: VBoxContainer = $Layout/Content/ChoicesRow/VBoxContainer
@onready var menu_image: TextureRect = $Layout/Content/ChoicesRow/TextureRect
@onready var title: Label = $Layout/Content/TitleGroup/TitleRow/Title
@onready var choices_row: HBoxContainer = $Layout/Content/ChoicesRow

var new_game_dialog: Node


func _ready() -> void:
	continue_button.disabled = not _save_manager().has_progress()
	_create_new_game_dialog()
	_configure_start_orientation()
	get_viewport().size_changed.connect(_update_responsive_layout)
	_update_responsive_layout()


func _configure_start_orientation() -> void:
	if OS.get_name() != "Android":
		return

	var screen_size := DisplayServer.screen_get_size()
	var screen_dpi := DisplayServer.screen_get_dpi()
	var screen_diagonal_inches := screen_size.length() / screen_dpi if screen_dpi > 0 else 0.0
	var is_tablet := screen_diagonal_inches >= 7.5
	DisplayServer.screen_set_orientation(
		DisplayServer.SCREEN_SENSOR_LANDSCAPE if is_tablet else DisplayServer.SCREEN_SENSOR_PORTRAIT
	)


func _update_responsive_layout() -> void:
	var viewport_size := get_viewport_rect().size
	var landscape := viewport_size.x > viewport_size.y
	var show_image := landscape and viewport_size.x >= 1050.0 and viewport_size.y >= 560.0
	var is_android := OS.get_name() == "Android"
	menu_image.visible = show_image
	choices_row.alignment = BoxContainer.ALIGNMENT_CENTER
	var compact := viewport_size.y < 700.0
	var image_height := clampf(viewport_size.y * 0.66, 420.0, 590.0) if not is_android else 420.0
	menu_image.custom_minimum_size = Vector2(image_height * 0.56, image_height)
	menu_buttons.custom_minimum_size.x = clampf(viewport_size.x * 0.82, 320.0, 760.0) if not show_image else (480.0 if not is_android else 400.0)
	title.add_theme_font_size_override("font_size", 34 if compact else (62 if not is_android else (52 if landscape else 45)))
	$Layout/Content/Subtitle.add_theme_font_size_override("font_size", 22 if compact else (36 if not is_android else 30))
	var button_height := 86.0 if not landscape else (70.0 if compact else (96.0 if not is_android else 78.0))
	var button_font_size := 36 if not landscape else (30 if compact else (42 if not is_android else 36))
	for button in menu_buttons.get_children():
		if button is Button:
			button.custom_minimum_size.y = button_height
			button.add_theme_font_size_override("font_size", button_font_size)


func _create_new_game_dialog() -> void:
	new_game_dialog = CONFIRMATION_DIALOG_SCENE.instantiate()
	add_child(new_game_dialog)
	new_game_dialog.connect("confirmed", _start_new_game)
	new_game_dialog.connect("canceled", _continue_saved_game)


func _on_start_button_pressed() -> void:
	if _save_manager().has_progress():
		new_game_dialog.call("show_confirmation",
			"Saved game found",
			"A game is already in progress. Start a new game and replace it, or continue your saved game?",
			"New Game",
			"Continue"
		)
		return
	_start_new_game()


func _start_new_game() -> void:
	_open_game(_save_manager().reset_to_default(), 0)


func _on_continue_button_pressed() -> void:
	if not _save_manager().has_progress():
		return
	_continue_saved_game()


func _continue_saved_game() -> void:
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
