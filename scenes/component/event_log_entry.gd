extends PanelContainer

@export var action: Action
@export var animation_duration: float = 0.35
@export var board_change_style: StyleBoxFlat
@export var action_style: StyleBoxFlat
@export var info_style: StyleBoxFlat
@export var error_style: StyleBoxFlat
@export var default_style: StyleBoxFlat

var spawn_tween: Tween
var swipe_tween: Tween
var swipe_origin_x: float = 0.0
var is_dismissing: bool = false

@onready var title_label: Label = %Title
@onready var action_text: RichTextLabel = %ActionText
@onready var accent: Panel = %Accent


func _ready() -> void:
	if action != null:
		_render_event()


func initialize(new_event: Action) -> void:
	action = new_event
	if is_node_ready() and action != null:
		_render_event()


func _render_event() -> void:
	title_label.text = action.title if not action.title.is_empty() else _type_title()
	action_text.clear()
	if action.display_text.is_empty():
		action_text.add_text(action.text)
	else:
		action_text.parse_bbcode(action.display_text)
	_apply_type_color()
	_play_spawn_animation()


func _apply_type_color() -> void:
	var style: StyleBoxFlat = default_style
	match action.type:
		EnumTypes.ActionType.BOARD_CHANGE:
			style = board_change_style
		EnumTypes.ActionType.ACTION:
			style = action_style
		EnumTypes.ActionType.INFO:
			style = info_style
		EnumTypes.ActionType.ERROR:
			style = error_style
	if style != null:
		accent.add_theme_stylebox_override("panel", style)


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
	spawn_tween = create_tween().set_parallel(true)
	spawn_tween.tween_property(
		self, "scale", Vector2.ONE, animation_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	spawn_tween.tween_property(
		self, "modulate:a", 1.0, animation_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func begin_swipe() -> void:
	if spawn_tween != null and spawn_tween.is_valid():
		spawn_tween.kill()
	if swipe_tween != null and swipe_tween.is_valid():
		swipe_tween.kill()
	swipe_origin_x = position.x
	scale = Vector2.ONE
	modulate.a = 1.0


func update_swipe(distance: float) -> void:
	if is_dismissing:
		return
	position.x = swipe_origin_x + distance
	modulate.a = clampf(1.0 - absf(distance) / maxf(size.x, 1.0) * 0.65, 0.35, 1.0)


func cancel_swipe() -> void:
	if is_dismissing or not is_inside_tree():
		return
	swipe_tween = create_tween().set_parallel(true)
	swipe_tween.tween_property(self, "position:x", swipe_origin_x, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	swipe_tween.tween_property(self, "modulate:a", 1.0, 0.18)


func dismiss(direction: float = 1.0) -> void:
	if is_dismissing:
		return
	is_dismissing = true
	if spawn_tween != null and spawn_tween.is_valid():
		spawn_tween.kill()
	if swipe_tween != null and swipe_tween.is_valid():
		swipe_tween.kill()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var target_x := position.x + signf(direction) * (size.x + 80.0)
	swipe_tween = create_tween().set_parallel(true)
	swipe_tween.tween_property(self, "position:x", target_x, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	swipe_tween.tween_property(self, "modulate:a", 0.0, 0.22)
	await swipe_tween.finished
	if is_inside_tree():
		queue_free()
