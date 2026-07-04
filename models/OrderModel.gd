extends Resource
class_name OrderModel


@export var orderState: EnumTypes.OrderState
@export var value: int
@export var state: StateType.StateType
@export var hasWriter: bool = false

func isClosed() -> bool:
	return orderState == EnumTypes.OrderState.CLOSED

func isOpen() -> bool:
	return orderState == EnumTypes.OrderState.OPEN

func close():
	orderState = EnumTypes.OrderState.CLOSED
	if hasWriterOnOrder():
		print("Removed Writer from Order in State:" + str(orderState) + "because it has been closed!")
		removeWriterFromOrder()
	

func open():
	orderState = EnumTypes.OrderState.OPEN

func hasWriterOnOrder()-> bool:
	return hasWriter
	
func removeWriterFromOrder():
	hasWriter = false
