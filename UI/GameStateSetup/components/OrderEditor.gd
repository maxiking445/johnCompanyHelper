extends PanelContainer

@onready var order_title: Label = $Content/OrderTitle
@onready var status_options: OptionButton = $Content/Controls/StatusOptions
@onready var writer_field: HBoxContainer = $Content/Controls/WriterField
@onready var writer_checkbox: CheckBox = writer_field.get_node("CheckBox")


func configure(order: OrderModel, compact: bool) -> void:
	order_title.text = "%s · £%d" % [order.id, order.value]
	order_title.add_theme_font_size_override("font_size", 30 if compact else 28)
	status_options.configure(compact)
	status_options.add_item("Open", EnumTypes.OrderState.OPEN)
	status_options.add_item("Closed", EnumTypes.OrderState.CLOSED)
	status_options.select(status_options.get_item_index(order.orderState))
	writer_field.configure(order.hasWriter, compact)
	writer_field.set_label("Has writer")
	writer_checkbox.disabled = order.isClosed()
	writer_field.value_changed.connect(func(enabled: bool): order.hasWriter = enabled)
	status_options.item_selected.connect(
		func(index: int):
			order.orderState = status_options.get_item_id(index) as EnumTypes.OrderState
			if order.isClosed():
				order.hasWriter = false
			writer_field.configure(order.hasWriter, compact)
			writer_checkbox.disabled = order.isClosed()
	)
