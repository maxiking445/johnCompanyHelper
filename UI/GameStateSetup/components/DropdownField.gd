extends OptionButton

const INPUT_STYLE := preload("res://UI/GameStateSetup/components/input_field_style.tres")

@export var desktop_minimum_size := Vector2(160, 88)
@export var compact_height := 96.0
@export var popup_font_size := 35
@export var popup_vertical_separation := 16


func _ready() -> void:
	custom_minimum_size = desktop_minimum_size
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_font_size_override("font_size", popup_font_size)
	add_theme_color_override("font_color", Color("2b190f"))
	add_theme_color_override("font_hover_color", Color("71131f"))
	add_theme_stylebox_override("normal", INPUT_STYLE)
	add_theme_stylebox_override("hover", INPUT_STYLE)
	add_theme_stylebox_override("pressed", INPUT_STYLE)
	get_popup().add_theme_font_size_override("font_size", popup_font_size)
	get_popup().add_theme_constant_override("v_separation", popup_vertical_separation)


func configure(compact: bool) -> void:
	custom_minimum_size.y = compact_height if compact else desktop_minimum_size.y
