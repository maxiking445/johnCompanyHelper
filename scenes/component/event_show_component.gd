extends Control

@export var topDeckEvent: IndiaEvent
@export var currentDeckEvent: IndiaEvent
@export var move_duration: float = 0.55

var is_animating_current_card: bool = false
var move_tween: Tween

@onready var current_event_card = $CurrentDeckCard/CurrentEventCard
@onready var top_deck_event_card = $TopDeckCard/TopDeckEventCard
@onready var current_card_target: Marker2D = $CurrentDeckCard/Marker2D
@onready var initial_current_card_position: Vector2 = current_event_card.position
@onready var initial_current_card_scale: Vector2 = current_event_card.scale
@onready var initial_current_card_pivot_offset: Vector2 = current_event_card.pivot_offset

var hasFlipped: bool = false

signal flipFinished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TopDeckCard.hide()
	$CurrentDeckCard/Label.hide()


func initialize_events(
	new_top_deck_event: IndiaEvent,
	new_current_deck_event: IndiaEvent,
	auto_flip: bool = false
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

	if auto_flip and currentDeckEvent != null:
		await get_tree().create_timer(0.3).timeout
		_flip_current_event_card()


func reset() -> void:
	if move_tween != null and move_tween.is_valid():
		move_tween.kill()
	move_tween = null

	is_animating_current_card = false
	hasFlipped = false

	current_event_card.reset()
	top_deck_event_card.reset()
	current_event_card.position = initial_current_card_position
	current_event_card.scale = initial_current_card_scale
	current_event_card.pivot_offset = initial_current_card_pivot_offset

	$TopDeckCard.hide()
	$CurrentDeckCard/Label.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
	await _move_current_card_to_marker()
	is_animating_current_card = false
	$TopDeckCard.show()
	$CurrentDeckCard/Label.show()


func _move_current_card_to_marker() -> void:
	current_event_card.pivot_offset = current_event_card.size * 0.5

	# Position the card's visual center exactly on the marker.
	var target_position: Vector2 = current_card_target.position - current_event_card.pivot_offset
	var target_scale: Vector2 = top_deck_event_card.scale
	move_tween = create_tween().set_parallel(true)

	move_tween.tween_property(
		current_event_card,
		"position",
		target_position,
		move_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	move_tween.tween_property(
		current_event_card,
		"scale",
		target_scale,
		move_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	await move_tween.finished
	move_tween = null


func _on_current_event_card_flip_finished() -> void:
	flipFinished.emit()
