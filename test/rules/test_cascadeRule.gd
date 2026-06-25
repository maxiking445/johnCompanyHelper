extends GutTest

const CASCADE_RULE := preload("res://rules/CascadeRule.gd")
const GAME_STATE := preload("res://resources/gameState/GameState.tres")

var _rule: CascadeRule
var _game_state: GameState


func before_each() -> void:
	_rule = CASCADE_RULE.new()
	_game_state = GAME_STATE.duplicate(true)
	_open_all_orders()


func test_execute_location_closes_next_open_order_when_location_has_open_orders() -> void:
	assert_true(_game_state.bombay.orders[0].isOpen())
	assert_true(_game_state.bombay.orders[1].isOpen())
	assert_true(_game_state.bombay.orders[2].isOpen())

	_rule.execute_location(_game_state, StateType.StateType.BOMBAY)

	assert_true(_game_state.bombay.orders[0].isClosed())
	assert_true(_game_state.bombay.orders[1].isOpen())
	assert_true(_game_state.bombay.orders[2].isOpen())


func test_execute_location_cascades_to_connected_orders_when_location_is_closed() -> void:
	_close_all_orders(_game_state.bombay)
	var delhi_order := _find_order_by_path("res://resources/tradeOrders/DELIH_ORDER_3.tres")
	var punjab_order := _find_order_by_path("res://resources/tradeOrders/PUNJAB_ORDER_1.tres")
	var maratha_order := _find_order_by_path("res://resources/tradeOrders/MARATHA_ORDER_2.tres")
	var mysore_order := _find_order_by_path("res://resources/tradeOrders/MYSORE_ORDER_1.tres")

	_rule.execute_location(_game_state, StateType.StateType.BOMBAY)

	assert_true(delhi_order.isClosed())
	assert_true(punjab_order.isClosed())
	assert_true(maratha_order.isClosed())
	assert_true(mysore_order.isClosed())
	assert_true(_rule.allreadyCascadedLocations.is_empty())


func _close_all_orders(state: StateModel) -> void:
	for order in state.orders:
		order.close()


func _open_all_orders() -> void:
	for order in _game_state.orderGraph.orders:
		order.open()


func _find_order_by_path(path: String) -> OrderModel:
	for order in _game_state.orderGraph.orders:
		if order.resource_path == path:
			return order

	return null
