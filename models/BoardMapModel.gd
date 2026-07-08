extends Resource
class_name BoardMapModel

@export var elephantBorderMarker: Array[ElephantBorderMarkerModel]
@export var orderGraph: OrderGraphModel



func findConnectedOrders(order: OrderModel) -> Array[OrderModel]:
	if orderGraph == null:
		return []

	return orderGraph.getConnectedOrders(order)
