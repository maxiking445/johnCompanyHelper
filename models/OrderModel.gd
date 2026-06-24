extends Resource
class_name OrderModel


@export var orderState: EnumTypes.OrderState
@export var value: int
@export var state: StateType.StateType


func isClosed() -> bool:
	return orderState == EnumTypes.OrderState.CLOSED

func isOpen() -> bool:
	return orderState == EnumTypes.OrderState.OPEN

func close():
	orderState = EnumTypes.OrderState.CLOSED
	

func open():
	orderState = EnumTypes.OrderState.OPEN
