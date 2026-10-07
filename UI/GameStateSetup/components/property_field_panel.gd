extends PanelContainer
@export var compact_separation := 10
@export var desktop_separation := 20
@export var compact_label_font_size := 35
@export var desktop_label_font_size := 36
@export var label_color := Color("2b190f")
@export var desktop_label_width := 290.0
@export var nested_label_width := 250.0
@onready var horizontal_row: HBoxContainer = $HorizontalRow
@onready var vertical_column: VBoxContainer = $VerticalColumn

var active_row: Control
var active_label: Label


func configure(
	vertical: bool,
	compact: bool,
	is_array: bool,
	show_label: bool,
	label_text: String,
	nested: bool = false
) -> void:
	horizontal_row.visible = not vertical
	vertical_column.visible = vertical
	active_row = vertical_column if vertical else horizontal_row
	active_row.add_theme_constant_override("separation", compact_separation if compact else desktop_separation)
	active_label = active_row.get_node("FieldLabel")
	var field_slot: VBoxContainer = active_row.get_node("FieldSlot")
	field_slot.add_theme_constant_override("separation", compact_separation if compact else desktop_separation)
	active_label.visible = show_label
	active_label.text = label_text
	active_label.add_theme_color_override("font_color", label_color)
	active_label.add_theme_font_size_override("font_size", compact_label_font_size if compact else desktop_label_font_size)
	if not compact and not is_array:
		active_label.custom_minimum_size.x = nested_label_width if nested else desktop_label_width
	active_label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
		if compact or is_array
		else Control.SIZE_SHRINK_BEGIN
	)


func get_field_slot() -> Control:
	return active_row.get_node("FieldSlot")


func style_label(font_size: int, color: Color) -> void:
	active_label.add_theme_color_override("font_color", color)
	active_label.add_theme_font_size_override("font_size", font_size)
