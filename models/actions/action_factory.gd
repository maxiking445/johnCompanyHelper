class_name ActionFactory
extends RefCounted

const CHANGE_TOWER_LEVEL: Action = preload("res://resources/actions/ChangeTowerLevel.tres")
const CHANGE_UNREST: Action = preload("res://resources/actions/ChangeUnrest.tres")
const CASCADE: Action = preload("res://resources/actions/Cascade.tres")
const CLOSE_ORDERS: Action = preload("res://resources/actions/CloseOrders.tres")
const CREATE_EMPIRE: Action = preload("res://resources/actions/CreateEmpire.tres")
const DRAW_EVENT: Action = preload("res://resources/actions/DrawEvent.tres")
const ERROR: Action = preload("res://resources/actions/Error.tres")
const EXHAUST_TROOPS: Action = preload("res://resources/actions/ExhaustTroops.tres")
const INCREASE_UNREST: Action = preload("res://resources/actions/IncreaseUnrest.tres")
const INFORMATION: Action = preload("res://resources/actions/Information.tres")
const MOVE_ELEPHANT: Action = preload("res://resources/actions/MoveElephant.tres")
const OPEN_ORDERS: Action = preload("res://resources/actions/OpenOrders.tres")
const REMOVE_EMPIRE_FLAG: Action = preload("res://resources/actions/RemoveEmpireFlag.tres")
const REMOVE_OFFICER: Action = preload("res://resources/actions/RemoveOfficer.tres")
const REMOVE_SOLDIERS: Action = preload("res://resources/actions/RemoveSoldiers.tres")
const ADD_TROPHY: Action = preload("res://resources/actions/AddTrophy.tres")
const CHANGE_COMPANY_STANDING: Action = preload("res://resources/actions/ChangeCompanyStanding.tres")
const RESTORE_LOCAL_AUTHORITY: Action = preload("res://resources/actions/RestoreLocalAuthority.tres")
const DOMINATE_STATE: Action = preload("res://resources/actions/DominateState.tres")
const RESTORE_SOVEREIGNTY: Action = preload("res://resources/actions/RestoreSovereignty.tres")
const UPDATE_SHIP_STATUS: Action = preload("res://resources/actions/UpdateShipStatus.tres")
const WINDFALL_PAY_WRITERS: Action = preload("res://resources/actions/WindfallPayWriters.tres")
const STATE_STATUS: Action = preload("res://resources/actions/StateStatus.tres")
const BATTLE_STARTED: Action = preload("res://resources/actions/BattleStarted.tres")
const BATTLE_RESULT: Action = preload("res://resources/actions/BattleResult.tres")
const INVASION_RESULT: Action = preload("res://resources/actions/InvasionResult.tres")


static func ship_action(ship: String, sea_zone: String, status: String) -> Action:
	return _create(UPDATE_SHIP_STATUS, {
		"ship": ship,
		"sea_zone": sea_zone,
		"status": status,
	})


static func state_status_action(state: String, status: String) -> Action:
	return _create(STATE_STATUS, {"state": state, "status": status})


static func battle_started_action(
	attacker: String,
	defender: String,
	attack_strength: int,
	defense_strength: int
) -> Action:
	return _create(BATTLE_STARTED, {
		"attacker": attacker,
		"defender": defender,
		"attack_strength": attack_strength,
		"defense_strength": defense_strength,
	})


static func battle_result_action(
	attacker: String, defender: String, winner: String
) -> Action:
	return _create(BATTLE_RESULT, {
		"attacker": attacker, "defender": defender, "winner": winner,
	})


static func invasion_result_action(
	attacker: String, defender: String, succeeded: bool
) -> Action:
	return _create(INVASION_RESULT, {
		"attacker": attacker,
		"defender": defender,
		"outcome": "succeeded" if succeeded else "failed",
	})


static func cascade_action(origin: String, destination: String) -> Action:
	return _create(CASCADE, {"origin": origin, "destination": destination})


static func change_tower_level_action(
	state: String, old_value: int, new_value: int
) -> Action:
	return _create(CHANGE_TOWER_LEVEL, {
		"state": state, "old_value": old_value, "new_value": new_value,
	})


static func change_unrest_action(
	state: String, old_value: int, new_value: int
) -> Action:
	return _create(CHANGE_UNREST, {
		"state": state, "old_value": old_value, "new_value": new_value,
	})


static func exhaust_troops_action(state: String, amount: int) -> Action:
	return _create(EXHAUST_TROOPS, {"state": state, "amount": amount})


static func remove_officer_action(state: String) -> Action:
	return _create(REMOVE_OFFICER, {"state": state})


static func add_trophy_action(state: String) -> Action:
	return _create(ADD_TROPHY, {"state": state})


static func lower_company_standing_action(amount: int) -> Action:
	return _create(CHANGE_COMPANY_STANDING, {"amount": amount})


static func restore_local_authority_action(
	state: String, tower_level: int
) -> Action:
	return _create(RESTORE_LOCAL_AUTHORITY, {
		"state": state, "tower_level": tower_level,
	})


static func dominate_state_action(state: String, dominator: String) -> Action:
	return _create(DOMINATE_STATE, {"state": state, "dominator": dominator})


static func restore_sovereignty_action(state: String) -> Action:
	return _create(RESTORE_SOVEREIGNTY, {"state": state})


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


static func information_action(message: String) -> Action:
	return _create(INFORMATION, {"message": message})


static func windfall_pay_writers_action(target_region: String) -> Action:
	return _create(WINDFALL_PAY_WRITERS, {"target_region": target_region})


static func error_action(message: String) -> Action:
	return _create(ERROR, {"message": message})


static func _create(template: Action, values: Dictionary) -> Action:
	var action := template.duplicate(true) as Action
	action.configure(values)
	return action
