extends VBoxContainer

@export var title_font_size := 36
@export var header_separation := 12

@onready var title_label: Label = $Header/Title
@onready var add_button: Button = $Header/AddButton


func configure(title: String) -> void:
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", title_font_size)
	$Header.add_theme_constant_override("separation", header_separation)
