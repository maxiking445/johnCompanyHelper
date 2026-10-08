extends GutTest

const WINDFALL_EVENT_RULE := preload("res://rules/events/WindfallEventRule.gd")
const GAME_STATE := preload("res://resources/gameState/GameState1710.tres")
const WINDFALL_HYDERABAD := preload("res://resources/events/windfall/Windfall_HYP.tres")

var _rule: WindfallEventRule
var _game_state: GameState


func before_each() -> void:
	_rule = WINDFALL_EVENT_RULE.new()
	_game_state = GAME_STATE.duplicate(true)
	ActionManager.clear()
	EventHelper.draw_pile = [WINDFALL_HYDERABAD]
	EventHelper.discard_pile.clear()
	EventHelper.activeEvent = null


func after_each() -> void:
	ActionManager.clear()
	EventHelper.draw_pile.clear()
	EventHelper.discard_pile.clear()
	EventHelper.activeEvent = null


func test_execute_always_prompts_players_to_check_writers() -> void:
	_rule.execute(_game_state)

	assert_eq(ActionManager.get_action_count(), 1)
	var action := ActionManager.get_action(0)
	assert_eq(action.title, "Pay Writers")
	assert_true(action.text.contains("Check HYDERABAD"))
	assert_true(action.display_text.contains("[color=#6E0E1F]HYDERABAD[/color]"))
	assert_true(action.text.contains("Each player takes £1 from the bank"))
	assert_true(action.text.contains("all adjacent regions"))
