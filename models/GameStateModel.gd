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
