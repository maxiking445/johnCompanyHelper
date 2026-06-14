@tool
extends Control

@export var amount: int = 0
@export var title: String

func _ready() -> void:
	update_ui()


func _on_add_button_pressed() -> void:
	amount = amount + 1
	update_ui()


func _on_substract_button_pressed() -> void:
	if (amount == 0):
		return
	amount = amount - 1
	update_ui()


func update_ui():
	$HBoxContainer3/HBoxContainer2/Amount.text = str(amount)
	$HBoxContainer3/HBoxContainer/Title.text = title
