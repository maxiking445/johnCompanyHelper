@tool
extends Node2D


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
	$ClosedSprite.visible = tradeOrderStatus == EnumTypes.OrderState.CLOSED
	$WriterSprite.visible = (hasWriter)
