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


func test_execute_resolves_writers_on_orders() -> void:
	_set_writers_on_all_orders(_game_state.hyperbad)
	_set_writers_on_all_orders(_game_state.madras)
	_set_writers_on_all_orders(_game_state.mysore)
	_set_writers_on_all_orders(_game_state.maratha)
	_set_writers_on_all_orders(_game_state.bombay)
	var writer_counts_before := _writer_counts()

	_rule.execute(_game_state)

	assert_eq(_writer_counts(), writer_counts_before)


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
