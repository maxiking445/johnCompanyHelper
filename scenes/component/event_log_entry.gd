extends PanelContainer

@export var action: Action
@export var animation_duration: float = 0.35

@onready var title_label: Label = %Title
@onready var action_text: Label = %ActionText
@onready var done_button: Button = %DoneButton


func _ready() -> void:
	if action != null:
		_render_event()


func initialize(new_event: Action) -> void:
	action = new_event
	if is_node_ready() and action != null:
		_render_event()


func _render_event() -> void:
	title_label.text = action.title if not action.title.is_empty() else _type_title()
	action_text.text = action.text
	done_button.visible = action.type == EnumTypes.ActionType.BOARD_CHANGE
	_play_spawn_animation()


func _type_title() -> String:
	match action.type:
		EnumTypes.ActionType.BOARD_CHANGE:
			return "BOARD CHANGE"
		EnumTypes.ActionType.INFO:
			return "INFORMATION"
		EnumTypes.ActionType.ERROR:
			return "ATTENTION"
		_:
			return "ACTION"


func _play_spawn_animation() -> void:
	modulate.a = 0.0
	pivot_offset = size * 0.5
	scale = Vector2(0.985, 0.985)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(
		self, "scale", Vector2.ONE, animation_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		self, "modulate:a", 1.0, animation_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _on_done_button_pressed() -> void:
	queue_free()
