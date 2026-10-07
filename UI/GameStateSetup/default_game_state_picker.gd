extends PopupPanel
class_name DefaultGameStatePicker

signal game_state_selected(game_state: GameState, scenario: String)

const DEFAULT_GAME_STATES := {
	"1710": preload("res://resources/gameState/GameState1710.tres"),
	"1758": preload("res://resources/gameState/GameState1758.tres"),
	"1813": preload("res://resources/gameState/GameState1813.tres"),
}


func open() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	popup_centered(Vector2i(
		mini(680, int(viewport_size.x) - 32),
		mini(560, int(viewport_size.y) - 32)
	))


func _select_scenario(scenario: String) -> void:
	var default_state: GameState = DEFAULT_GAME_STATES.get(scenario)
	if default_state == null:
		push_error("Unknown default GameState: %s" % scenario)
		return
	game_state_selected.emit(default_state.duplicate(true), scenario)
	hide()


func _on_1710_button_pressed() -> void:
	_select_scenario("1710")


func _on_1758_button_pressed() -> void:
	_select_scenario("1758")


func _on_1813_button_pressed() -> void:
	_select_scenario("1813")
