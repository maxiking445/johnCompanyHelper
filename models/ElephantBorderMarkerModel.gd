extends Resource
class_name ElephantBorderMarkerModel

@export var shapes: Array[EnumTypes.ElephantMarker] = []

@export var state: StateType.StateType
@export var state_bordering: StateType.StateType

func hasMatchingShape(shape: EnumTypes.ElephantMarker)-> bool:
	var matches: bool = false
	for marker in shapes:
		if marker == shape:
			matches = true
	return matches


func getStateThatMatcheShape(shape: EnumTypes.ElephantMarker)-> StateType.StateType:
	var foundState: StateType.StateType 
	for marker in shapes:
		if marker == shape:
			foundState = state_bordering
	return foundState
