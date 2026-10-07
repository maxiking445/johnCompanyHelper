extends Control

const EVENT_LOG_ENTRY_SCENE := preload("res://scenes/component/EventLogEntry.tscn")
const GESTURE_DEADZONE := 18.0
const GESTURE_DIRECTION_RATIO := 1.1

@export var actionList: Array[Action]
@export var entry_delay: float = 0.2
@export var topDeckEvent: IndiaEvent
@export var currentEvent: IndiaEvent
@export var index: int
@export var round_number: int = 1

var remaining_card_count: int = 0

@onready var eventLogList: VBoxContainer = %EventLogList
@onready var event_counter: Label = %EventCounter
@onready var actions_heading: Label = $ActionsHeading
@onready var event_scroll: ScrollContainer = $ScrollContainer
@onready var event_list_margin: MarginContainer = $ScrollContainer/ListMargin
@onready var event_show_component = $EventShowComponent
@onready var info_button: Button = %InfoButton
@onready var info_dialog: Control = $InfoLayer/InfoDialog

var log_generation: int = 0
var displayed_log_index: int = -1
var pending_last_event: bool = false
var active_pointer_type: int = 0
var active_touch_index: int = -1
var touch_start: Vector2 = Vector2.ZERO
var last_touch_position: Vector2 = Vector2.ZERO
var gesture_axis: int = 0
var gesture_entry: Control
var last_touch_end_msec: int = -1000

signal lastEventShown
signal presentation_changed(revealed: bool)


func _ready() -> void:
	var counter_settings := event_counter.label_settings.duplicate() as LabelSettings
	counter_settings.font_size = 36
	counter_settings.outline_size = 0
	event_counter.label_settings = counter_settings
	var heading_settings := actions_heading.label_settings.duplicate() as LabelSettings
	heading_settings.font_size = 36
	heading_settings.outline_size = 0
	actions_heading.label_settings = heading_settings
	event_counter.show()
	actions_heading.hide()
	event_scroll.hide()
	get_viewport().size_changed.connect(_update_responsive_layout)
	_update_responsive_layout()


func _input(event: InputEvent) -> void:
	# Let the modal dialog receive input before the card hit-test below.
	if info_dialog.visible:
		return

	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			if event_show_component.try_flip_at_screen_position(touch.position):
				get_viewport().set_input_as_handled()
				return
			if active_pointer_type == 0:
				_start_gesture(touch.position, 1, touch.index)
		elif active_pointer_type == 1 and touch.index == active_touch_index:
			_finish_gesture(touch.position)
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if active_pointer_type == 1 and drag.index == active_touch_index:
			_drag_gesture(drag.position)
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed and event_show_component.try_flip_at_screen_position(mouse.position):
			get_viewport().set_input_as_handled()
			return
		if mouse.pressed and active_pointer_type == 0 and Time.get_ticks_msec() - last_touch_end_msec > 250:
			_start_gesture(mouse.position, 2)
		elif not mouse.pressed and active_pointer_type == 2:
			_finish_gesture(mouse.position)
	elif event is InputEventMouseMotion and active_pointer_type == 2:
		var motion := event as InputEventMouseMotion
		if motion.button_mask & MOUSE_BUTTON_MASK_LEFT:
			_drag_gesture(motion.position)


func _start_gesture(point: Vector2, pointer_type: int, touch_index: int = -1) -> void:
	if not event_scroll.visible or not event_scroll.get_global_rect().has_point(point):
		return
	var scrollbar := event_scroll.get_v_scroll_bar()
	if scrollbar.visible and scrollbar.get_global_rect().has_point(point):
		return
	active_pointer_type = pointer_type
	active_touch_index = touch_index
	touch_start = point
	last_touch_position = point
	gesture_axis = 0
	gesture_entry = _entry_at(point)
	event_scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_viewport().set_input_as_handled()


func _drag_gesture(point: Vector2) -> void:
	var movement := point - touch_start
	if gesture_axis == 0 and movement.length() >= GESTURE_DEADZONE:
		_lock_gesture_axis(movement)
	if gesture_axis == 1 and is_instance_valid(gesture_entry):
		gesture_entry.call("update_swipe", movement.x)
	elif gesture_axis == 2:
		_scroll_by(point.y - last_touch_position.y)
	last_touch_position = point
	get_viewport().set_input_as_handled()


func _finish_gesture(point: Vector2) -> void:
	var movement := point - touch_start
	if gesture_axis == 0 and movement.length() >= GESTURE_DEADZONE:
		_lock_gesture_axis(movement)
	if gesture_axis == 1 and is_instance_valid(gesture_entry):
		var minimum_distance := maxf(72.0, minf(event_scroll.size.x * 0.12, 140.0))
		if absf(movement.x) >= minimum_distance and absf(movement.x) > absf(movement.y) * GESTURE_DIRECTION_RATIO:
			gesture_entry.call("dismiss", signf(movement.x))
		else:
			gesture_entry.call("cancel_swipe")
	elif gesture_axis == 2:
		_scroll_by(point.y - last_touch_position.y)
	if active_pointer_type == 1:
		last_touch_end_msec = Time.get_ticks_msec()
	_reset_touch_gesture()
	get_viewport().set_input_as_handled()


func _lock_gesture_axis(movement: Vector2) -> void:
	if absf(movement.x) > absf(movement.y) * GESTURE_DIRECTION_RATIO and is_instance_valid(gesture_entry):
		gesture_axis = 1
		gesture_entry.call("begin_swipe")
	elif absf(movement.y) > absf(movement.x) * GESTURE_DIRECTION_RATIO:
		gesture_axis = 2


func _scroll_by(finger_delta_y: float) -> void:
	event_scroll.scroll_vertical -= roundi(finger_delta_y)


func _entry_at(point: Vector2) -> Control:
	for entry in eventLogList.get_children():
		if entry is Control and not entry.is_queued_for_deletion() and entry.get_global_rect().has_point(point):
			return entry
	return null


func _reset_touch_gesture() -> void:
	active_pointer_type = 0
	active_touch_index = -1
	gesture_axis = 0
	gesture_entry = null
	call_deferred("_restore_scroll_mouse_filter")


func _restore_scroll_mouse_filter() -> void:
	if active_pointer_type == 0:
		event_scroll.mouse_filter = Control.MOUSE_FILTER_STOP


func _cancel_touch_gesture() -> void:
	if gesture_axis == 1 and is_instance_valid(gesture_entry) and not gesture_entry.is_queued_for_deletion():
		gesture_entry.call("cancel_swipe")
	_reset_touch_gesture()


func _update_responsive_layout() -> void:
	var viewport_size := get_viewport_rect().size
	var portrait := viewport_size.y >= viewport_size.x
	var scroll_size: Vector2
	var scroll_position: Vector2
	if portrait:
		scroll_size = Vector2(maxf(280.0, viewport_size.x - 40.0), viewport_size.y * 0.46)
		scroll_position = Vector2((viewport_size.x - scroll_size.x) * 0.5, viewport_size.y * 0.44)
	else:
		scroll_size = Vector2(minf(1000.0, viewport_size.x * 0.38), minf(620.0, viewport_size.y * 0.4))
		scroll_position = Vector2(maxf(24.0, viewport_size.x * 0.03), viewport_size.y * 0.45)

	event_scroll.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	event_scroll.position = scroll_position
	event_scroll.size = scroll_size
	event_list_margin.custom_minimum_size.x = scroll_size.x
	eventLogList.custom_minimum_size.x = maxf(0.0, scroll_size.x - 80.0)
	for entry in eventLogList.get_children():
		if entry is Control:
			entry.custom_minimum_size.x = maxf(0.0, scroll_size.x - 80.0)

	actions_heading.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	actions_heading.position = Vector2(scroll_position.x, scroll_position.y - 48.0)
	actions_heading.size = Vector2(scroll_size.x, 42.0)
	event_counter.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	var info_size := 80.0 if portrait else 72.0
	info_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	info_button.position = Vector2(24.0, 24.0)
	info_button.size = Vector2(info_size, info_size)
	event_counter.position = Vector2(viewport_size.x - 224.0, 32.0)
	event_counter.size = Vector2(200.0, 56.0)
	event_counter.label_settings.font_size = 34 if portrait else 38
	info_button.z_index = 3
	event_counter.z_index = 3


func initialize(
	new_index: int,
	new_top_deck_event: IndiaEvent,
	new_current_event: IndiaEvent,
	new_round_number: int = 1
) -> void:
	index = new_index
	round_number = new_round_number
	topDeckEvent = new_top_deck_event
	currentEvent = new_current_event
	removeLog()
	actionList.clear()
	var played_event := EventHelper.getPlayedEventAt(index)
	remaining_card_count = played_event.remainingDeck.size()
	event_show_component.initialize_events(topDeckEvent, currentEvent, played_event.remainingDeck)
	_update_event_counter()
	_hide_initial_details()
	displayed_log_index = -1
	presentation_changed.emit(false)
	if index + 1 == EventHelper.getPlayedEvents().size():
		lastEventShown.emit()


func populate_event_log() -> void:
	removeLog()
	var generation := log_generation
	var actions := actionList.duplicate()
	for action in actions:
		if generation != log_generation:
			return
		var event_log_entry = EVENT_LOG_ENTRY_SCENE.instantiate()
		event_log_entry.custom_minimum_size.x = maxf(0.0, event_scroll.size.x - 80.0)
		event_log_entry.initialize(action)
		eventLogList.add_child(event_log_entry)
		if entry_delay > 0.0:
			await get_tree().create_timer(entry_delay).timeout


func _on_event_show_component_flip_finished() -> void:
	# Keep the next event's actions out of the UI model until its card is revealed.
	actionList = ActionManager.get_actions_by_event_id(currentEvent.eventId)
	_show_details()
	if displayed_log_index != index:
		populate_event_log()
		displayed_log_index = index
	if pending_last_event:
		pending_last_event = false
		lastEventShown.emit()


func _show_details() -> void:
	event_counter.show()
	for control in [actions_heading, event_scroll]:
		control.modulate.a = 1.0
		control.show()
	event_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	presentation_changed.emit(true)


func _hide_initial_details() -> void:
	event_counter.show()
	for control in [actions_heading, event_scroll]:
		control.hide()
	event_scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE


func next() -> void:
	var event_count := EventHelper.getPlayedEvents().size()
	var next_index := index + 1
	if next_index >= event_count:
		return

	var played_event: PlayedEvent = EventHelper.getPlayedEventAt(next_index)
	topDeckEvent = played_event.topdeckEvent
	currentEvent = played_event.currentEvent
	remaining_card_count = played_event.remainingDeck.size()
	actionList.clear()
	_cancel_touch_gesture()
	event_scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	removeLog()
	displayed_log_index = -1
	for control in [actions_heading, event_scroll]:
		control.hide()
	index = next_index
	pending_last_event = index + 1 == event_count
	_update_event_counter()
	presentation_changed.emit(false)
	event_show_component.present_next_event(topDeckEvent, currentEvent, played_event.remainingDeck)


func is_card_animating() -> bool:
	return event_show_component.is_animating_current_card or event_show_component.awaiting_flip


func _update_event_counter() -> void:
	var event_count := EventHelper.getPlayedEvents().size()
	event_counter.text = "%d/%d" % [index + 1, event_count]


func _on_info_button_pressed() -> void:
	var event_count := EventHelper.getPlayedEvents().size()
	var current_event_name := "Unknown" if currentEvent == null else currentEvent.eventName
	var current_location := "Unknown" if currentEvent == null else StateType.name(currentEvent.eventLocation)
	var current_event_id := "N/A" if currentEvent == null else str(currentEvent.eventId)
	var next_card_info := "No next card"
	if topDeckEvent != null:
		next_card_info = "%s — %s (ID %d)" % [
			topDeckEvent.eventName,
			StateType.name(topDeckEvent.eventLocation),
			topDeckEvent.eventId
		]
	var message := "ROUND: %d\nEVENT: %d OF %d\nCARDS IN DECK: %d\n\nCURRENT EVENT: %s — %s\nCURRENT EVENT CARD ID: %s\nTOP DECK CARD: %s" % [
		round_number,
		index + 1,
		event_count,
		remaining_card_count,
		current_event_name,
		current_location,
		current_event_id,
		next_card_info
	]
	info_dialog.call("show_info", "GAME INFO", message)


func removeLog() -> void:
	_cancel_touch_gesture()
	log_generation += 1
	event_scroll.scroll_vertical = 0
	for child in eventLogList.get_children():
		child.queue_free()
