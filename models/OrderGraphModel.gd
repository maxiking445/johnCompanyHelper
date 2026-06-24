extends Resource
class_name OrderGraphModel

@export var orders: Array[OrderModel]
@export var connections: Array[Resource]


func getConnectedOrders(order: OrderModel) -> Array[OrderModel]:
	var result: Array[OrderModel] = []

	for connection in connections:
		if connection.from == order:
			result.append(connection.to)
		elif connection.to == order:
			result.append(connection.from)

	return result
