extends Control

@export var topDeckEvent: IndiaEvent
@export var currentDeckEvent: IndiaEvent
@export var card_move_duration: float = 0.65

var is_animating_current_card: bool = false
var move_tween: Tween

@onready var current_event_card = $CurrentDeckCard/CurrentEventCard
@onready var top_deck_event_card = $TopDeckCard/TopDeckEventCard
@onready var current_deck_label: Label = $CurrentDeckCard/Label
@onready var top_deck_label: Label = $TopDeckCard/Label

var hasFlipped: bool = false
var initial_card_scale: Vector2 = Vector2.ONE
var target_card_scale: Vector2 = Vector2.ONE
var current_card_target_position: Vector2 = Vector2.ZERO

signal flipFinished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TopDeckCard.hide()
	current_deck_label.hide()
	top_deck_label.label_settings = top_deck_label.label_settings.duplicate()
	top_deck_label.label_settings.font_size = 34
	top_deck_label.label_settings.outline_size = 0
	current_deck_label.label_settings = current_deck_label.label_settings.duplicate()
	current_deck_label.label_settings.font_size = 38
	current_deck_label.label_settings.outline_size = 0
	get_viewport().size_changed.connect(_update_card_layout)
	_update_card_layout()


func _update_card_layout() -> void:
	var viewport_size := get_viewport_rect().size
	var portrait := viewport_size.y >= viewport_size.x
	var card_size: Vector2 = current_event_card.size
	var initial_extent := minf(viewport_size.x * 0.84, viewport_size.y * 0.49) if portrait else minf(viewport_size.x * 0.43, viewport_size.y * 0.60)
	var target_extent := minf(viewport_size.x * 0.46, viewport_size.y * 0.34) if portrait else minf(viewport_size.x * 0.36, viewport_size.y * 0.70)
	initial_card_scale = Vector2.ONE * clampf(initial_extent / card_size.x, 0.85, 1.6)
	target_card_scale = Vector2.ONE * clampf(target_extent / card_size.x, 0.55 if portrait else 0.8, 1.5)
	var current_center: Vector2
	var top_deck_center: Vector2

	if portrait:
		current_center = Vector2(viewport_size.x * 0.75, viewport_size.y * 0.245)
		top_deck_center = Vector2(viewport_size.x * 0.25, viewport_size.y * 0.245)
	else:
		current_center = Vector2(viewport_size.x * 0.68, viewport_size.y * 0.49)
		top_deck_center = Vector2(viewport_size.x * 0.23, viewport_size.y * 0.23)

	current_event_card.pivot_offset = card_size * 0.5
	top_deck_event_card.pivot_offset = card_size * 0.5
	top_deck_event_card.scale = target_card_scale * (0.85 if portrait else 0.65)
	$TopDeckCard.position = top_deck_center - card_size * 0.5
	$TopDeckCard.size = card_size
	top_deck_event_card.position = Vector2.ZERO
	current_card_target_position = current_center - card_size * 0.5
	if not is_animating_current_card:
		current_event_card.position = current_card_target_position if hasFlipped else viewport_size * 0.5 - card_size * 0.5
		current_event_card.scale = target_card_scale if hasFlipped else initial_card_scale
	current_deck_label.position = Vector2(current_center.x - current_deck_label.size.x * 0.5, current_center.y - card_size.y * target_card_scale.y * 0.5 - current_deck_label.size.y - 12.0)
	top_deck_label.position = Vector2((card_size.x - top_deck_label.size.x) * 0.5, card_size.y * 0.5 - card_size.y * top_deck_event_card.scale.y * 0.5 - top_deck_label.size.y - 12.0)


func initialize_events(
	new_top_deck_event: IndiaEvent,
	new_current_deck_event: IndiaEvent
) -> void:
	reset()
	topDeckEvent = new_top_deck_event
	currentDeckEvent = new_current_deck_event

	if topDeckEvent != null:
		top_deck_event_card.set_textures(
			topDeckEvent.front_sprite,
			topDeckEvent.back_sprite
		)
	else:
		top_deck_event_card.set_textures(null, null)

	if currentDeckEvent != null:
		current_event_card.set_textures(
			currentDeckEvent.front_sprite,
			currentDeckEvent.back_sprite
		)
	else:
		current_event_card.set_textures(null, null)

func reset() -> void:
	if move_tween != null and move_tween.is_valid():
		move_tween.kill()
	move_tween = null
	is_animating_current_card = false
	hasFlipped = false
	_update_card_layout()

	current_event_card.reset()
	top_deck_event_card.reset()

	$TopDeckCard.hide()
	current_deck_label.hide()


func _on_current_event_card_gui_input(event: InputEvent) -> void:
	if hasFlipped:
		return
	if not event is InputEventMouseButton:
		return

	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return

	if is_animating_current_card or current_event_card.is_flipping:
		return

	_flip_current_event_card()


func _flip_current_event_card() -> void:
	if hasFlipped or is_animating_current_card or current_event_card.is_flipping:
		return

	hasFlipped = true
	is_animating_current_card = true
	current_event_card.flip()
	await current_event_card.flip_finished
	if not is_inside_tree():
		return
	$TopDeckCard.show()
	$TopDeckCard.modulate.a = 0.0
	current_deck_label.show()
	current_deck_label.modulate.a = 0.0
	flipFinished.emit()
	move_tween = create_tween().set_parallel(true)
	move_tween.tween_property(
		current_event_card,
		"position",
		current_card_target_position,
		card_move_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	move_tween.tween_property(current_event_card, "scale", target_card_scale, card_move_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	move_tween.tween_property($TopDeckCard, "modulate:a", 1.0, 0.35)
	move_tween.tween_property(current_deck_label, "modulate:a", 1.0, 0.35)
	await move_tween.finished
	move_tween = null
	is_animating_current_card = false
	_update_card_layout()
