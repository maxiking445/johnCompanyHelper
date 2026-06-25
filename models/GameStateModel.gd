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

@export var orderGraph: Resource

@export var companyStanding: int

@export var seaWest: SeaModel
@export var seaEast: SeaModel
@export var seaSouth: SeaModel

var eventsToDraw: int
var states: Array[StateModel] = [
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
	for state in states:
		if state != null && state.location == location:
			return state

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

func findConnectedOrders(order: OrderModel) -> Array[OrderModel]:
	if orderGraph == null:
		return []

	return orderGraph.getConnectedOrders(order)

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
	for state in states:
		if state.unrest_size > 0:
			statesWithUnrest.append(state)
	return statesWithUnrest

func areAllOrderClosed(location: StateType.StateType) -> bool:
	var state: StateModel = findStateByLocation(location)
	var areAllClosed = true
	for order in state.orders:
		if order.orderState == EnumTypes.OrderState.OPEN:
			areAllClosed = false
	return areAllClosed

func lowerCompanyStanding(number: int):
	companyStanding = companyStanding - number
