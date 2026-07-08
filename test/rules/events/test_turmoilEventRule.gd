extends GutTest

const TURMOIL_EVENT_RULE := preload("res://rules/events/TurmoilEventRule.gd")
const GAME_STATE := preload("res://resources/gameState/GameState.tres")
const TURMOIL_BOMBAY := preload("res://resources/events/turmoil/Turmoil_BOM.tres")

var _rule: TurmoilEventRule
var _game_state: GameState


func before_each() -> void:
	_rule = TURMOIL_EVENT_RULE.new()
	_game_state = GAME_STATE.duplicate(true)
	_open_all_orders()
	EventHelper.draw_pile = [TURMOIL_BOMBAY]
	EventHelper.discard_pile.clear()
	EventHelper.activeEvent = null


func after_each() -> void:
	EventHelper.draw_pile.clear()
	EventHelper.discard_pile.clear()
	EventHelper.activeEvent = null


func test_execute_closes_trade_orders_in_event_location() -> void:
	assert_false(_game_state.areAllOrderClosed(StateType.StateType.BOMBAY))
	assert_true(_game_state.bombay.orders[0].isOpen())
	assert_true(_game_state.bombay.orders[1].isOpen())
	assert_true(_game_state.bombay.orders[2].isOpen())

	_rule.execute(_game_state)

	assert_true(_game_state.bombay.orders[0].isClosed())
	assert_true(_game_state.bombay.orders[1].isOpen())
	assert_true(_game_state.bombay.orders[2].isOpen())


func test_execute_closes_next_open_order_when_first_order_is_already_closed() -> void:
	_game_state.bombay.orders[0].close()

	_rule.execute(_game_state)

	assert_true(_game_state.bombay.orders[0].isClosed())
	assert_true(_game_state.bombay.orders[1].isClosed())
	assert_true(_game_state.bombay.orders[2].isOpen())


func test_execute_does_not_cascade_when_event_location_still_has_open_orders() -> void:
	var delhi_order := _game_state.findOrderById(&"DEL_3")
	var punjab_order := _game_state.findOrderById(&"PUN_1")
	var mysore_order := _game_state.findOrderById(&"MYS_1")

	_rule.execute(_game_state)

	assert_true(delhi_order.isOpen())
	assert_true(punjab_order.isOpen())
	assert_true(mysore_order.isOpen())


func test_execute_cascades_to_connected_region_orders_when_location_is_already_closed() -> void:
	_close_all_orders(_game_state.bombay)

	var delhi_order := _game_state.findOrderById(&"DEL_3")
	var punjab_order := _game_state.findOrderById(&"PUN_1")
	var maratha_order := _game_state.findOrderById(&"MAR_2")
	var mysore_order := _game_state.findOrderById(&"MYS_1")

	assert_true(delhi_order.isOpen())
	assert_true(punjab_order.isOpen())
	assert_true(maratha_order.isOpen())
	assert_true(mysore_order.isOpen())

	_rule.execute(_game_state)

	assert_true(delhi_order.isClosed())
	assert_true(punjab_order.isClosed())
	assert_true(maratha_order.isClosed())
	assert_true(mysore_order.isClosed())


func test_execute_recursively_cascades_when_connected_order_is_already_closed() -> void:
	_close_all_orders(_game_state.bombay)
	_close_all_orders(_game_state.delhi)

	var punjab_order := _game_state.findOrderById(&"PUN_1")
	var maratha_order := _game_state.findOrderById(&"MAR_1")

	assert_true(punjab_order.isOpen())
	assert_true(maratha_order.isOpen())

	_rule.execute(_game_state)

	assert_true(punjab_order.isClosed())
	assert_true(maratha_order.isClosed())


func test_execute_clears_cascaded_locations_after_cascade() -> void:
	_close_all_orders(_game_state.bombay)

	_rule.execute(_game_state)

	assert_true(_rule.cascadeRule.allreadyCascadedLocations.is_empty())


func _close_all_orders(state: StateModel) -> void:
	for order in state.orders:
		order.close()


func _open_all_orders() -> void:
	for state in _game_state.getStates():
		for order in state.orders:
			order.open()
