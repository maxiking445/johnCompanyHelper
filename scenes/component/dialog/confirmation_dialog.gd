extends ColorRect

signal confirmed
signal canceled

@onready var dialog_panel: PanelContainer = %DialogPanel
@onready var title_label: Label = %Title
@onready var message_label: Label = %Message
@onready var confirm_button: Button = %ConfirmButton
@onready var cancel_button: Button = %CancelButton


func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	get_viewport().size_changed.connect(_update_responsive_layout)
	_update_responsive_layout()


func show_confirmation(dialog_title: String, message: String, confirm_text: String, cancel_text: String) -> void:
	title_label.text = dialog_title
	message_label.text = message
	confirm_button.text = confirm_text
	cancel_button.text = cancel_text
	_update_responsive_layout()
	visible = true
	confirm_button.grab_focus()


func _update_responsive_layout() -> void:
	var viewport_size := get_viewport_rect().size
	var compact := viewport_size.x < 620.0
	dialog_panel.custom_minimum_size.x = maxf(0.0, minf(viewport_size.x - 32.0, 560.0))
	confirm_button.custom_minimum_size = Vector2(136.0 if compact else 190.0, 60.0 if compact else 68.0)
	cancel_button.custom_minimum_size = confirm_button.custom_minimum_size
	confirm_button.add_theme_font_size_override("font_size", 22 if compact else 28)
	cancel_button.add_theme_font_size_override("font_size", 22 if compact else 28)
	message_label.add_theme_font_size_override("font_size", 17 if compact else 19)
	title_label.add_theme_font_size_override("font_size", 21 if compact else 25)


func _on_confirm_pressed() -> void:
	visible = false
	confirmed.emit()


func _on_cancel_pressed() -> void:
	visible = false
	canceled.emit()


func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_on_cancel_pressed()
		get_viewport().set_input_as_handled()
