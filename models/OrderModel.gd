extends Resource
class_name OrderModel


@export var id: StringName
@export var orderState: EnumTypes.OrderState
@export var value: int
@export var state: StateType.StateType

func isClosed() -> bool:
	return orderState == EnumTypes.OrderState.CLOSED

func isOpen() -> bool:
	return orderState == EnumTypes.OrderState.OPEN

func close():
	if isClosed():
		return
	orderState = EnumTypes.OrderState.CLOSED
	ActionManager.add_action(
		ActionFactory.close_orders_action(StateType.name(state), 1)
	)

func open():
	if isOpen():
		return
	orderState = EnumTypes.OrderState.OPEN
	ActionManager.add_action(
		ActionFactory.open_orders_action(StateType.name(state), 1)
	)
