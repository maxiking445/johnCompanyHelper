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

@export var seaWest: SeaModel
@export var seaEast: SeaModel
@export var seaSouth: SeaModel

var eventsToDraw: int

func findStateByLocation(location: StateType.StateType) -> StateModel:
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

	for state in states:
		if state != null && state.location == location:
			return state

	return null


func findConnectedLocations(location: StateType.StateType)-> Array[StateType.StateType]:
	var state: StateModel = findStateByLocation(location)
	return state.is_connected_to

func closeNorthestOrder(location: StateType.StateType):
	var state: StateModel = findStateByLocation(location)

	for order in state.orders:
		if order.orderState == EnumTypes.OrderState.OPEN:
			order.close()
	printerr("Everythhing was already closed. This is an implentation Error. Check before!")
	push_error("Exception!")


func areAllOrderClosed(location: StateType.StateType) -> bool:
	var state: StateModel = findStateByLocation(location)
	var areAllClosed = true
	for order in state.orders:
		if order.orderState == EnumTypes.OrderState.OPEN:
			areAllClosed = false
	return areAllClosed
