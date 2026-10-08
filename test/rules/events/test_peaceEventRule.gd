extends GutTest

const PEACE_EVENT_RULE := preload("res://rules/events/PeaceEventRule.gd")

var _rule: PeaceEventRule
var _game_state: GameState
var _elephant: ElephantModel


func before_each() -> void:
	_rule = PEACE_EVENT_RULE.new()
	_game_state = GameState.new()
	_elephant = ElephantModel.new()
	_game_state.elephant = _elephant
	EventHelper.draw_pile = [_create_event(StateType.StateType.BOMBAY)]
	EventHelper.discard_pile.clear()
	EventHelper.activeEvent = null


func after_each() -> void:
	EventHelper.draw_pile.clear()
	EventHelper.discard_pile.clear()
	EventHelper.activeEvent = null


func test_execute_opens_orders_and_resets_unrest_when_elephant_is_inside_state() -> void:
	var punjab := _create_state(StateType.StateType.PUNJAB)
	punjab.unrest_size = 3
	punjab.orders = [_create_order(EnumTypes.OrderState.CLOSED), _create_order(EnumTypes.OrderState.CLOSED)]
	var bombay := _create_state(StateType.StateType.BOMBAY)
	bombay.isCompanyControlled = true
	_game_state.states = [punjab, bombay]
	_elephant.placeInCenterOf(StateType.StateType.PUNJAB)

	_rule.execute(_game_state)

	assert_eq(punjab.unrest_size, 0)
	assert_true(punjab.orders[0].isOpen())
	assert_true(punjab.orders[1].isOpen())
	assert_true(_elephant.is_inside_state())
	assert_eq(_elephant.current_state, StateType.StateType.BOMBAY)


func test_execute_adds_tower_only_to_non_company_state_when_elephant_is_on_border() -> void:
	var punjab := _create_state(StateType.StateType.PUNJAB)
	punjab.towerLevel = 1
	var bengal := _create_state(StateType.StateType.BENGAL)
	bengal.towerLevel = 2
	bengal.isCompanyControlled = true
	var bombay := _create_state(StateType.StateType.BOMBAY)
	bombay.isCompanyControlled = true
	_game_state.states = [punjab, bengal, bombay]
	_elephant.placeOnBorderOf(StateType.StateType.PUNJAB, StateType.StateType.BENGAL)

	_rule.execute(_game_state)

	assert_eq(punjab.towerLevel, 2)
	assert_eq(bengal.towerLevel, 2)
	assert_true(_elephant.is_inside_state())
	assert_eq(_elephant.current_state, StateType.StateType.BOMBAY)


func _create_state(location: StateType.StateType) -> StateModel:
	var state := StateModel.new()
	state.location = location
	return state


func _create_order(order_state: EnumTypes.OrderState) -> OrderModel:
	var order := OrderModel.new()
	order.orderState = order_state
	return order


func _create_event(location: StateType.StateType) -> IndiaEvent:
	var event := IndiaEvent.new()
	event.eventLocation = location
	return event


func test_peace_opens_only_orders_connected_across_elephant_border() -> void:
	var bombay := _create_state(StateType.StateType.BOMBAY)
	bombay.orders = [
		_create_named_order(&"BOM_3", bombay.location),
		_create_named_order(&"BOM_1", bombay.location),
	]
	var mysore := _create_state(StateType.StateType.MYSORE)
	mysore.orders = [
		_create_named_order(&"MYS_1", mysore.location),
		_create_named_order(&"MYS_2", mysore.location),
	]
	_game_state.states = [bombay, mysore]
	_elephant.placeOnBorderOf(bombay.location, mysore.location)

	# BOM_3 and MYS_1 are linked across this border in OrderGraph.tres.
	_rule._open_orders_across_border(_game_state, _elephant.getTouchingLocations())

	assert_true(bombay.orders[0].isOpen())
	assert_true(mysore.orders[0].isOpen())
	assert_true(bombay.orders[1].isClosed())
	assert_true(mysore.orders[1].isClosed())


func _create_named_order(order_id: StringName, location: StateType.StateType) -> OrderModel:
	var order := _create_order(EnumTypes.OrderState.CLOSED)
	order.id = order_id
	order.state = location
	return order
