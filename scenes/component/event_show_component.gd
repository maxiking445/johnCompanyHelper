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
@onready var stack_layers: Control = %StackLayers

var hasFlipped: bool = false
var awaiting_flip: bool = false
var remaining_deck_snapshot: Array[IndiaEvent] = []
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
	stack_layers.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	stack_layers.position = Vector2.ZERO
	stack_layers.size = card_size
	stack_layers.pivot_offset = card_size * 0.5
	stack_layers.scale = top_deck_event_card.scale
	_update_stack_layers()
	current_card_target_position = current_center - card_size * 0.5
	if not is_animating_current_card:
		current_event_card.position = current_card_target_position if hasFlipped else viewport_size * 0.5 - card_size * 0.5
		current_event_card.scale = target_card_scale if hasFlipped else initial_card_scale
	current_deck_label.position = Vector2(current_center.x - current_deck_label.size.x * 0.5, current_center.y - card_size.y * target_card_scale.y * 0.5 - current_deck_label.size.y - 12.0)
	top_deck_label.position = Vector2((card_size.x - top_deck_label.size.x) * 0.5, card_size.y * 0.5 - card_size.y * top_deck_event_card.scale.y * 0.5 - top_deck_label.size.y - 12.0)


func initialize_events(
	new_top_deck_event: IndiaEvent,
	new_current_deck_event: IndiaEvent,
	remaining_deck: Array[IndiaEvent] = []
) -> void:
	reset()
	topDeckEvent = new_top_deck_event
	currentDeckEvent = new_current_deck_event
	remaining_deck_snapshot = remaining_deck.duplicate()

	if topDeckEvent != null:
		top_deck_event_card.set_textures(
			topDeckEvent.front_sprite,
			topDeckEvent.back_sprite
		)
	else:
		top_deck_event_card.set_textures(null, null)
	_update_stack_layers()

	if currentDeckEvent != null:
		current_event_card.set_textures(
			currentDeckEvent.front_sprite,
			currentDeckEvent.back_sprite
		)
	else:
		current_event_card.set_textures(null, null)


func _update_stack_layers() -> void:
	for child in stack_layers.get_children():
		child.free()

	# The visible TopDeckEventCard is the first card in this snapshot.
	# Each backing plate represents one real card underneath it.
	var hidden_card_count := maxi(remaining_deck_snapshot.size() - 1, 0)
	var displayed_card_width: float = top_deck_event_card.size.x * top_deck_event_card.scale.x
	var max_stack_offset: float = minf(34.0, displayed_card_width * 0.14)
	var screen_pitch: float = minf(1.25, max_stack_offset / maxf(hidden_card_count, 1))
	var local_pitch: float = screen_pitch / maxf(top_deck_event_card.scale.x, 0.01)
	for deck_index in range(remaining_deck_snapshot.size() - 1, 0, -1):
		var card_layer := TextureRect.new()
		card_layer.name = "CardLayer_%02d" % deck_index
		card_layer.position = Vector2(-deck_index * local_pitch, -deck_index * local_pitch)
		card_layer.size = top_deck_event_card.size
		card_layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		card_layer.stretch_mode = TextureRect.STRETCH_SCALE
		card_layer.texture = remaining_deck_snapshot[deck_index].back_sprite
		card_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stack_layers.add_child(card_layer)

func reset() -> void:
	if move_tween != null and move_tween.is_valid():
		move_tween.kill()
	move_tween = null
	is_animating_current_card = false
	hasFlipped = false
	awaiting_flip = false
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


func try_flip_at_screen_position(screen_position: Vector2) -> bool:
	if hasFlipped or is_animating_current_card or current_event_card.is_flipping:
		return false
	if not current_event_card.get_global_rect().has_point(screen_position):
		return false
	_flip_current_event_card()
	return true


func _flip_current_event_card() -> void:
	if hasFlipped or is_animating_current_card or current_event_card.is_flipping:
		return

	hasFlipped = true
	awaiting_flip = false
	is_animating_current_card = true
	await _flip_and_move_current_card(true)


func present_next_event(
	new_top_deck_event: IndiaEvent,
	new_current_deck_event: IndiaEvent,
	remaining_deck: Array[IndiaEvent]
) -> void:
	if is_animating_current_card:
		return
	is_animating_current_card = true
	hasFlipped = false
	awaiting_flip = false
	topDeckEvent = new_top_deck_event
	currentDeckEvent = new_current_deck_event
	remaining_deck_snapshot = remaining_deck.duplicate()
	current_event_card.reset()
	top_deck_event_card.reset()
	current_event_card.set_textures(currentDeckEvent.front_sprite, currentDeckEvent.back_sprite)
	top_deck_event_card.set_textures(topDeckEvent.front_sprite, topDeckEvent.back_sprite)
	_update_stack_layers()

	# Promote the old top card visually while revealing the next card on the stack.
	$TopDeckCard.show()
	$TopDeckCard.modulate.a = 1.0
	top_deck_label.show()
	current_deck_label.hide()
	current_event_card.pivot_offset = current_event_card.size * 0.5
	current_event_card.position = $TopDeckCard.position
	current_event_card.scale = top_deck_event_card.scale
	current_event_card.modulate.a = 1.0
	var center_position: Vector2 = get_viewport_rect().size * 0.5 - current_event_card.size * 0.5
	move_tween = create_tween().set_parallel(true)
	move_tween.tween_property(current_event_card, "position", center_position, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	move_tween.tween_property(current_event_card, "scale", initial_card_scale, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await move_tween.finished
	move_tween = null
	_update_card_layout()
	is_animating_current_card = false
	awaiting_flip = true


func _flip_and_move_current_card(reveal_top_deck_after_flip: bool) -> void:
	current_event_card.flip()
	await current_event_card.flip_finished
	if not is_inside_tree():
		return
	if reveal_top_deck_after_flip:
		$TopDeckCard.show()
		$TopDeckCard.modulate.a = 0.0
		top_deck_label.show()
		current_deck_label.show()
		current_deck_label.modulate.a = 0.0
	else:
		current_deck_label.show()
		current_deck_label.modulate.a = 0.0
	move_tween = create_tween().set_parallel(true)
	move_tween.tween_property(
		current_event_card,
		"position",
		current_card_target_position,
		card_move_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	move_tween.tween_property(current_event_card, "scale", target_card_scale, card_move_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	if reveal_top_deck_after_flip:
		move_tween.tween_property($TopDeckCard, "modulate:a", 1.0, 0.35)
	move_tween.tween_property(current_deck_label, "modulate:a", 1.0, 0.35)
	await move_tween.finished
	move_tween = null
	is_animating_current_card = false
	_update_card_layout()
	flipFinished.emit()
