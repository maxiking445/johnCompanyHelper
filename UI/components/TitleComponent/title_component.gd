@tool
extends Control


@export var title: String
@export var color: Color



func _ready() -> void:
	update_ui()


func update_ui() -> void:
	$HBoxContainer/MarginContainer/Title.text = title
	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	style.bg_color = color
	add_theme_stylebox_override("panel", style)
