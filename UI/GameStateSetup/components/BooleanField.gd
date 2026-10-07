extends HBoxContainer

signal value_changed(enabled: bool)

@export var checkbox_size := Vector2(64, 88)
@export var compact_height := 96.0
@export var label_font_size := 35

@onready var checkbox: CheckBox = $CheckBox


func configure(value: bool, compact: bool) -> void:
	checkbox.custom_minimum_size = Vector2(checkbox_size.x, compact_height if compact else checkbox_size.y)
	checkbox.button_pressed = value
	$ValueLabel.add_theme_font_size_override("font_size", label_font_size)


func set_label(text: String) -> void:
	$ValueLabel.text = text


func _on_checkbox_toggled(enabled: bool) -> void:
	value_changed.emit(enabled)
