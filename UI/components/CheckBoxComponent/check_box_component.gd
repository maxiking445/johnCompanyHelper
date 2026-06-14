@tool
extends Control

@export var isChecked: bool
@export var title: String

func _ready() -> void:
	$HBoxContainer3/HBoxContainer/Title.text = title


func update_ui() -> void:
	pass


func _on_check_box_pressed() -> void:
	print("Check button pressed!")
