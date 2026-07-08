extends Resource
class_name BoardMapModel

@export var elephantBorderMarker: Array[ElephantBorderMarkerModel]
@export var orderGraph: OrderGraphModel

func findConnectedOrderIds(order_id: StringName) -> Array[StringName]:
	if orderGraph == null:
		return []

	return orderGraph.getConnectedOrderIds(order_id)


func findTheStateWhichTheElephantWillBorderWith(state: StateType.StateType, shape: EnumTypes.ElephantMarker) -> StateType.StateType:
	for borderMarker in elephantBorderMarker:
		if borderMarker.isState(state):
			if borderMarker.hasMatchingShape(shape):
				return borderMarker.getBorderStateThatMatcheShape(shape)
	return StateType.StateType.NONE


func findTheNextBorderOfThatState(state: StateType.StateType, borderingState: StateType.StateType ) -> StateType.StateType:
	for borderMarker in elephantBorderMarker:
		if borderMarker.isState(state) && !borderMarker.isBorderingState(borderingState):
			return borderMarker.state_bordering	
	return StateType.StateType.NONE
