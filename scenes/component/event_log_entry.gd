extends Control

@export var event: Action
@export var animation_duration: float = 0.35
@export var slide_distance: float = 45.0

@onready var panel: PanelContainer = $PanelContainer


func _ready() -> void:
	if event != null:
		_render_event()


func initialize(new_event: Action) -> void:
	event = new_event
	if is_node_ready() and event != null:
		_render_event()


func _render_event() -> void:
	$PanelContainer/MarginContainer/VBoxContainer/ActionText.text = event.text
	_play_spawn_animation()


func _play_spawn_animation() -> void:
	modulate.a = 0.0
	panel.position.y += slide_distance

	var target_panel_y := panel.position.y - slide_distance
	var tween := create_tween().set_parallel(true)

	tween.tween_property(
		panel,
		"position:y",
		target_panel_y,
		animation_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self,
		"modulate:a",
		1.0,
		animation_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _on_done_button_pressed() -> void:
	queue_free()
