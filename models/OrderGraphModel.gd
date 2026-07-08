extends Resource
class_name OrderGraphModel

@export var connections: Array[Resource]


func getConnectedOrderIds(order_id: StringName) -> Array[StringName]:
	var result: Array[StringName] = []

	for connection in connections:
		if connection.from_id == order_id:
			result.append(connection.to_id)
		elif connection.to_id == order_id:
			result.append(connection.from_id)

	return result
