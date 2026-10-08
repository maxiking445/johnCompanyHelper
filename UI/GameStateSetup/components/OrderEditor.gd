extends PanelContainer

@onready var order_title: Label = $Content/OrderTitle
@onready var status_options: OptionButton = $Content/Controls/StatusOptions


func configure(order: OrderModel, compact: bool) -> void:
	order_title.text = "%s · £%d" % [order.id, order.value]
	order_title.add_theme_font_size_override("font_size", 30 if compact else 28)
	status_options.configure(compact)
	status_options.add_item("Open", EnumTypes.OrderState.OPEN)
	status_options.add_item("Closed", EnumTypes.OrderState.CLOSED)
	status_options.select(status_options.get_item_index(order.orderState))
	status_options.item_selected.connect(
		func(index: int):
			order.orderState = status_options.get_item_id(index) as EnumTypes.OrderState
	)
