extends Resource
class_name OrderModel


@export var orderState: EnumTypes.OrderState
@export var value: int
@export var state: StateType.StateType
@export var connectedOrders: Array[OrderModel]


func close():
	orderState = EnumTypes.OrderState.CLOSED
	

func open():
	orderState = EnumTypes.OrderState.OPEN
