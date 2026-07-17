extends Resource
class_name GameState

@export var bombay: StateModel
@export var madras: StateModel
@export var hyperbad: StateModel
@export var punjab: StateModel
@export var bengal: StateModel
@export var maratha: StateModel
@export var delhi: StateModel
@export var mysore: StateModel
@export var elephant: ElephantModel

@export var companyStanding: int

@export var seaWest: SeaModel
@export var seaEast: SeaModel
@export var seaSouth: SeaModel


@export var hadASucessfullInvasionCrisis: bool
@export var sucessFullInvasionCapital: StateType.StateType

@export var eventsToDraw: int
var states: Array[StateModel] = []

func getStates() -> Array[StateModel]:
	if not states.is_empty():
		return states

	return [
		bombay,
		madras,
		hyperbad,
		punjab,
		bengal,
		maratha,
		delhi,
		mysore
	]
	
func findStateByLocation(location: StateType.StateType) -> StateModel:
	for state in getStates():
		if state != null && state.location == location:
			return state

	return null

func findOrderById(order_id: StringName) -> OrderModel:
	for state in getStates():
		if state == null:
			continue
		for order in state.orders:
			if order.id == order_id:
				return order

	return null

func isStateSovereign(location: StateType.StateType) -> bool:
	var state: StateModel = findStateByLocation(location)
	return state.isSovereign

func findConnectedTradeNodes(location: StateType.StateType)-> Array[StateType.StateType]:
	var state: StateModel = findStateByLocation(location)
	return state.is_connected_to

func findConnectedLocations(location: StateType.StateType)-> Array[StateType.StateType]:
	var state: StateModel = findStateByLocation(location)
	return state.is_connected_to


func closeNorthestOrder(location: StateType.StateType):
	var state: StateModel = findStateByLocation(location)

	for order in state.orders:
		if order.orderState == EnumTypes.OrderState.OPEN:
			order.close()
			return
	printerr("Everythhing was already closed. This is an implentation Error. Check before!")
	push_error("Exception!")
	
func findAllStatesWithUnrest()-> Array[StateModel]:
	var statesWithUnrest: Array[StateModel] = []
	for state in getStates():
		if state != null && state.unrest_size > 0:
			statesWithUnrest.append(state)
	return statesWithUnrest

func areAllOrderClosed(location: StateType.StateType) -> bool:
	var state: StateModel = findStateByLocation(location)
	var areAllClosed = true
	for order in state.orders:
		if order.orderState == EnumTypes.OrderState.OPEN:
			areAllClosed = false
	return areAllClosed
	
func closeAllOrders(location: StateType.StateType):
	var state: StateModel = findStateByLocation(location)
	for order in state.orders:
		order.close()


func openAllOrders(location: StateType.StateType):
	var state: StateModel = findStateByLocation(location)
	for order in state.orders:
		order.open()

func lowerCompanyStanding(number: int):
	var old_value := companyStanding
	companyStanding = companyStanding - number
	ActionManager.add_action(
		ActionFactory.change_company_standing_action(old_value, companyStanding)
	)


func get_sea_name(sea: SeaModel) -> String:
	if sea == seaWest:
		return "West Sea"
	if sea == seaEast:
		return "East Sea"
	if sea == seaSouth:
		return "South Sea"
	return "Unknown Sea"


func set_events_to_draw(event_count: int) -> void:
	eventsToDraw = event_count


func mark_successful_invasion_crisis(capital: StateType.StateType) -> void:
	hadASucessfullInvasionCrisis = true
	sucessFullInvasionCapital = capital


func consume_successful_invasion_capital() -> StateType.StateType:
	if not hadASucessfullInvasionCrisis:
		return StateType.StateType.NONE
	var capital := sucessFullInvasionCapital
	hadASucessfullInvasionCrisis = false
	sucessFullInvasionCapital = StateType.StateType.NONE
	return capital


func dissolve_empire(empire: EnumTypes.Empires) -> void:
	if empire == EnumTypes.Empires.NONE:
		return
	for state in getAllStatesOfEmpire(empire):
		state.remove_empire_flag()

func getAllStatesOfEmpire(empire: EnumTypes.Empires)-> Array[StateModel]:
	var statesOfEmpire: Array[StateModel] = []
	for state in getStates():
		if state.partOfEmpire == empire:
			statesOfEmpire.append(state)
	return statesOfEmpire
	
func findFreeEmpireFlags():
	var used_empires: Array[EnumTypes.Empires] = []
	for state in getStates():
		if state != null and state.isPartOfEmpire():
			used_empires.append(state.partOfEmpire)

	for empire in [
		EnumTypes.Empires.A,
		EnumTypes.Empires.B,
		EnumTypes.Empires.C,
	]:
		if not used_empires.has(empire):
			return empire

	return EnumTypes.Empires.NONE

func findEmpireCapital( state: StateModel) -> StateModel:
	if state.isEmpireCapital or not state.isPartOfEmpire():
		return state
	for empire_state in getAllStatesOfEmpire(state.partOfEmpire):
		if empire_state.isSovereignCapital:
			return empire_state
	push_error("There is no valid SovereignCapital")
	return null
		
