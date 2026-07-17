class_name ActionFactory
extends RefCounted

const CHANGE_TREASURY: Action = preload("res://resources/actions/ChangeTreasury.tres")
const CLOSE_ORDERS: Action = preload("res://resources/actions/CloseOrders.tres")
const CREATE_EMPIRE: Action = preload("res://resources/actions/CreateEmpire.tres")
const DRAW_EVENT: Action = preload("res://resources/actions/DrawEvent.tres")
const ERROR: Action = preload("res://resources/actions/Error.tres")
const INCREASE_UNREST: Action = preload("res://resources/actions/IncreaseUnrest.tres")
const INFORMATION: Action = preload("res://resources/actions/Information.tres")
const MOVE_ELEPHANT: Action = preload("res://resources/actions/MoveElephant.tres")
const OPEN_ORDERS: Action = preload("res://resources/actions/OpenOrders.tres")
const REMOVE_EMPIRE_FLAG: Action = preload("res://resources/actions/RemoveEmpireFlag.tres")
const REMOVE_SOLDIERS: Action = preload("res://resources/actions/RemoveSoldiers.tres")
const UPDATE_SHIP_STATUS: Action = preload("res://resources/actions/UpdateShipStatus.tres")
const WINDFALL_PAY_WRITERS: Action = preload("res://resources/actions/WindfallPayWriters.tres")


static func ship_action(ship: String, sea_zone: String, status: String) -> Action:
	return _create(UPDATE_SHIP_STATUS, {
		"ship": ship,
		"sea_zone": sea_zone,
		"status": status,
	})


static func close_orders_action(state: String, order_count: int) -> Action:
	return _create(CLOSE_ORDERS, {
		"state": state,
		"order_count": order_count,
	})


static func open_orders_action(state: String, order_count: int) -> Action:
	return _create(OPEN_ORDERS, {
		"state": state,
		"order_count": order_count,
	})


static func remove_soldiers_action(
	state: String,
	owner: String,
	soldier_count: int
) -> Action:
	return _create(REMOVE_SOLDIERS, {
		"state": state,
		"owner": owner,
		"soldier_count": soldier_count,
	})


static func increase_unrest_action(
	state: String,
	old_value: int,
	new_value: int
) -> Action:
	return _create(INCREASE_UNREST, {
		"state": state,
		"old_value": old_value,
		"new_value": new_value,
	})


static func change_treasury_action(
	state: String,
	old_value: int,
	new_value: int
) -> Action:
	return _create(CHANGE_TREASURY, {
		"state": state,
		"old_value": old_value,
		"new_value": new_value,
	})


static func draw_event_action(event: String, location: String) -> Action:
	return _create(DRAW_EVENT, {
		"event": event,
		"location": location,
	})


static func create_empire_action(empire: String, capital: String) -> Action:
	return _create(CREATE_EMPIRE, {
		"empire": empire,
		"capital": capital,
	})


static func remove_empire_flag_action(empire: String, state: String) -> Action:
	return _create(REMOVE_EMPIRE_FLAG, {
		"empire": empire,
		"state": state,
	})


static func move_elephant_action(
	origin: String,
	destination: String,
	marker: String
) -> Action:
	return _create(MOVE_ELEPHANT, {
		"origin": origin,
		"destination": destination,
		"marker": marker,
	})


static func windfall_pay_writers_action(state: String, amount: int) -> Action:
	return _create(WINDFALL_PAY_WRITERS, {
		"state": state,
		"amount": amount,
	})


static func information_action(message: String) -> Action:
	return _create(INFORMATION, {"message": message})


static func error_action(message: String) -> Action:
	return _create(ERROR, {"message": message})


static func _create(template: Action, values: Dictionary) -> Action:
	var action := template.duplicate(true) as Action
	action.configure(values)
	return action
