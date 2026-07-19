extends Control

@export var move_duration: float = 0.55

var is_animating_current_card: bool = false

@onready var current_event_card = $CurrentDeckCard/CurrentEventCard
@onready var top_deck_event_card = $TopDeckCard/TopDeckEventCard
@onready var current_card_target: Marker2D = $CurrentDeckCard/Marker2D


var hasFlipped: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	var tween := create_tween().set_parallel(true)

	tween.tween_property(
		current_event_card,
		"position",
		target_position,
		move_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		current_event_card,
		"scale",
		target_scale,
		move_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	await tween.finished
