extends LineEdit

@export var desktop_minimum_size := Vector2(160, 88)
@export var compact_height := 96.0
@export var input_font_size := 35

func configure(value: String, compact: bool, placeholder: String = "", numeric: bool = false) -> void:
	text = value
	placeholder_text = placeholder
	custom_minimum_size = Vector2(desktop_minimum_size.x, compact_height if compact else desktop_minimum_size.y)
	add_theme_font_size_override("font_size", input_font_size)
	virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER if numeric else LineEdit.KEYBOARD_TYPE_DEFAULT
