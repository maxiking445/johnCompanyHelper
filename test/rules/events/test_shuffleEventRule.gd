extends GutTest

const SHUFFLE_EVENT_RULE := preload("res://rules/events/ShuffleEventRule.gd")
const SHUFFLE_MADRAS := preload("res://resources/events/shuffle/Shuffle_MAD.tres")
const TURMOIL_BOMBAY := preload("res://resources/events/turmoil/Turmoil_BOM.tres")
const WINDFALL_HYPERBAD := preload("res://resources/events/windfall/Windfall_HYP.tres")
const GAME_STATE := preload("res://resources/gameState/GameState.tres")

var _rule: ShuffleEventRule
var _game_state: GameState


func before_each() -> void:
	_rule = SHUFFLE_EVENT_RULE.new()
	_game_state = GAME_STATE.duplicate(true)
	EventHelper.draw_pile = [TURMOIL_BOMBAY]
	EventHelper.discard_pile = [SHUFFLE_MADRAS, WINDFALL_HYPERBAD]
	EventHelper.activeEvent = SHUFFLE_MADRAS


func after_each() -> void:
	EventHelper.draw_pile.clear()
	EventHelper.discard_pile.clear()
	EventHelper.activeEvent = null


func test_execute_moves_active_event_back_into_draw_pile_and_empties_discard_pile() -> void:
	_rule.execute(_game_state)

	assert_true(EventHelper.draw_pile.has(SHUFFLE_MADRAS))
	assert_true(EventHelper.draw_pile.has(TURMOIL_BOMBAY))
	assert_true(EventHelper.draw_pile.has(WINDFALL_HYPERBAD))
	assert_eq(EventHelper.draw_pile.size(), 3)
	assert_true(EventHelper.discard_pile.is_empty())


func test_execute_keeps_active_event_set_for_caller_to_clear() -> void:
	_rule.execute(_game_state)

	assert_eq(EventHelper.activeEvent, SHUFFLE_MADRAS)
