@tool
extends Control


@export var title: String
@export var color: Color
@export var panel_style: StyleBoxFlat



func _ready() -> void:
	update_ui()


func update_ui() -> void:
	$HBoxContainer/MarginContainer/Title.text = title
	var style := panel_style
	if style == null:
		style = get_theme_stylebox("panel") as StyleBoxFlat
	if style == null:
		return
	var instance_style := style.duplicate() as StyleBoxFlat
	instance_style.bg_color = color
	add_theme_stylebox_override("panel", instance_style)
