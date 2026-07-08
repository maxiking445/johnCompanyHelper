extends Node

const boardMap: BoardMapModel = preload("res://resources/boardMap.tres")



func findConnectedOrders(order: OrderModel) -> Array[OrderModel]:
	if boardMap.orderGraph == null:
		return []

	return boardMap.orderGraph.getConnectedOrders(order)


func findTheStateWhichTheElephantWillBorderWith(state: StateType.StateType, shape: EnumTypes.ElephantMarker) -> StateType.StateType:
	for borderMarker in boardMap.elephantBorderMarker:
		if borderMarker.isState(state):
			if borderMarker.hasMatchingShape(shape):
				return borderMarker.getBorderStateThatMatcheShape(shape)
	return StateType.StateType.NONE



func findTheNextBorderOfThatState(state: StateType.StateType, borderingState: StateType.StateType ) -> StateType.StateType:
	for borderMarker in boardMap.elephantBorderMarker:
		if borderMarker.isState(state) && !borderMarker.isBorderingState(borderingState):
			return borderMarker.state_bordering	
	return StateType.StateType.NONE
