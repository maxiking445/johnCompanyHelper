extends GutTest

const WINDFALL_EVENT_RULE := preload("res://rules/events/WindfallEventRule.gd")
const GAME_STATE := preload("res://resources/gameState/GameState1710.tres")
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


func test_execute_resolves_writers_on_orders_without_changing_game_state() -> void:
	_set_writers_on_all_orders(_game_state.hyperbad)
	_game_state.hyperbad.treasury_size = 10
	_set_writers_on_all_orders(_game_state.madras)
	_game_state.madras.treasury_size = 20
	_set_writers_on_all_orders(_game_state.mysore)
	_game_state.mysore.treasury_size = 30
	_set_writers_on_all_orders(_game_state.maratha)
	_game_state.maratha.treasury_size = 40
	_set_writers_on_all_orders(_game_state.bombay)
	_game_state.bombay.treasury_size = 50
	var writer_counts_before := _writer_counts()

	_rule.execute(_game_state)

	assert_eq(_writer_counts(), writer_counts_before)
	assert_eq(_game_state.hyperbad.treasury_size, 10)
	assert_eq(_game_state.madras.treasury_size, 20)
	assert_eq(_game_state.mysore.treasury_size, 30)
	assert_eq(_game_state.maratha.treasury_size, 40)
	assert_eq(_game_state.bombay.treasury_size, 50)


func _set_writers_on_all_orders(state: StateModel) -> void:
	for order in state.orders:
		order.hasWriter = true


func _writer_counts() -> Array[int]:
	return [
		_game_state.hyperbad.getWritersAmountInState(),
		_game_state.madras.getWritersAmountInState(),
		_game_state.mysore.getWritersAmountInState(),
		_game_state.maratha.getWritersAmountInState(),
		_game_state.bombay.getWritersAmountInState(),
	]
