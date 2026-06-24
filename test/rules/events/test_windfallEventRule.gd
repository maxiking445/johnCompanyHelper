extends GutTest

const WINDFALL_EVENT_RULE := preload("res://rules/events/WindfallEventRule.gd")
const GAME_STATE := preload("res://resources/gameState/GameState.tres")
const WINDFALL_HYPERBAD := preload("res://resources/events/windfall/Windfall_HYP.tres")

var _rule: WindfallEventRule
var _game_state: GameState


func before_each() -> void:
	_rule = WINDFALL_EVENT_RULE.new()
	_game_state = GAME_STATE.duplicate(true)
	EventHelper.draw_pile = [WINDFALL_HYPERBAD]
	EventHelper.discard_pile.clear()
	EventHelper.activeEvent = null


func after_each() -> void:
	EventHelper.draw_pile.clear()
	EventHelper.discard_pile.clear()
	EventHelper.activeEvent = null


func test_execute_logs_one_windfall_per_writer_without_changing_game_state() -> void:
	_game_state.hyperbad.writers = 2
	_game_state.hyperbad.treasury_size = 10
	_game_state.madras.writers = 3
	_game_state.madras.treasury_size = 20
	_game_state.mysore.writers = 4
	_game_state.mysore.treasury_size = 30
	_game_state.maratha.writers = 5
	_game_state.maratha.treasury_size = 40
	_game_state.bombay.writers = 7
	_game_state.bombay.treasury_size = 50

	_rule.execute(_game_state)

	assert_eq(_rule.windfallLogMessages.size(), 14)
	assert_eq(_rule.windfallLogMessages.count("Writer in HYPERBAD gains 1$"), 2)
	assert_eq(_rule.windfallLogMessages.count("Writer in MADRAS gains 1$"), 3)
	assert_eq(_rule.windfallLogMessages.count("Writer in MYSORE gains 1$"), 4)
	assert_eq(_rule.windfallLogMessages.count("Writer in MARATHA gains 1$"), 5)
	assert_eq(_rule.windfallLogMessages.count("Writer in BOMBAY gains 1$"), 0)

	assert_eq(_game_state.hyperbad.treasury_size, 10)
	assert_eq(_game_state.madras.treasury_size, 20)
	assert_eq(_game_state.mysore.treasury_size, 30)
	assert_eq(_game_state.maratha.treasury_size, 40)
	assert_eq(_game_state.bombay.treasury_size, 50)
