@tool
extends Node2D
class_name TradeOrderComponent


@export var orderModel: OrderModel:
	set(value):
		orderModel = value
		if is_node_ready():
			updateUI()


@export var tradeOrderStatus: EnumTypes.OrderState:
	set(value):
		tradeOrderStatus = value
		if is_node_ready():
			updateUI()

@export var hasWriter: bool = false:
	set(value):
		hasWriter = value
		if is_node_ready():
			updateUI()


func _ready() -> void:
	updateUI()


func updateUI() -> void:
	if orderModel == null:
		$ClosedSprite.hide()
		$WriterSprite.hide()
		$Label.show()
		return

	var status := orderModel.orderState if orderModel != null else tradeOrderStatus
	var writer := hasWriter
	$ClosedSprite.visible = status == EnumTypes.OrderState.CLOSED
	$WriterSprite.visible = writer
	$Label.hide()
