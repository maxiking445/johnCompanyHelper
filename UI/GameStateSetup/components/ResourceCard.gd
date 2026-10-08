extends PanelContainer

@export var title_font_size := 35

@onready var title_label: Label = $Content/Header/Title
@onready var remove_button: Button = $Content/Header/RemoveButton
@onready var content: VBoxContainer = $Content


func configure(title: String, removable: bool) -> void:
	title_label.text = title
	remove_button.visible = removable
	if removable:
		title_label.add_theme_font_size_override("font_size", title_font_size)
