extends HBoxContainer

const INPUT_STYLE := preload("res://UI/GameStateSetup/components/input_field_style.tres")

@export var minimum_value := -9999.0
@export var maximum_value := 9999.0
@export var compact_control_size := Vector2(96, 96)
@export var desktop_control_size := Vector2(88, 88)
@export var compact_spin_size := Vector2(160, 96)
@export var desktop_spin_size := Vector2(160, 88)
@export var control_font_size := 34
@export var input_font_size := 35

signal value_changed(value: float)

@onready var spin_box: SpinBox = $SpinBox
@onready var minus_button: Button = $MinusButton
@onready var plus_button: Button = $PlusButton


func configure(value: float, integer_value: bool, compact: bool) -> void:
	spin_box.min_value = minimum_value
	spin_box.max_value = maximum_value
	spin_box.step = 1 if integer_value else 0.1
	spin_box.value = value
	spin_box.custom_minimum_size = compact_spin_size if compact else desktop_spin_size
	spin_box.get_line_edit().add_theme_font_size_override("font_size", input_font_size)
	spin_box.get_line_edit().add_theme_color_override("font_color", Color("2b190f"))
	spin_box.get_line_edit().add_theme_stylebox_override(
		"normal", INPUT_STYLE
	)
	spin_box.get_line_edit().add_theme_stylebox_override(
		"focus", INPUT_STYLE
	)
	spin_box.get_line_edit().virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	minus_button.custom_minimum_size = compact_control_size if compact else desktop_control_size
	minus_button.add_theme_font_size_override("font_size", control_font_size)
	plus_button.custom_minimum_size = compact_control_size if compact else desktop_control_size
	plus_button.add_theme_font_size_override("font_size", control_font_size)


func _on_spin_box_value_changed(value: float) -> void:
	value_changed.emit(value)


func _on_minus_button_pressed() -> void:
	spin_box.value -= spin_box.step


func _on_plus_button_pressed() -> void:
	spin_box.value += spin_box.step
