extends ScrollContainer

const ENTRY_SCENE := preload("res://scenes/component/EventLogEntry.tscn")
const GESTURE_DEADZONE := 18.0
const GESTURE_DIRECTION_RATIO := 1.1
@onready var entries: VBoxContainer = $ListMargin/Entries
var active_pointer_type := 0
var active_touch_index := -1
var touch_start := Vector2.ZERO
var last_touch_position := Vector2.ZERO
var gesture_axis := 0
var gesture_entry: Control
var last_touch_end_msec := -1000


func display_actions(actions: Array[Action]) -> void:
	for child in entries.get_children():
		child.queue_free()
	for action in actions:
		var entry := ENTRY_SCENE.instantiate()
		entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		entry.initialize(action)
		entries.add_child(entry)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return

	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
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
		if mouse.pressed and mouse.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN] and get_global_rect().has_point(mouse.position):
			scroll_vertical += -100 if mouse.button_index == MOUSE_BUTTON_WHEEL_UP else 100
			get_viewport().set_input_as_handled()
			return
		if mouse.button_index != MOUSE_BUTTON_LEFT:
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
	if not self.visible or not self.get_global_rect().has_point(point):
		return
	var scrollbar := self.get_v_scroll_bar()
	if scrollbar.visible and scrollbar.get_global_rect().has_point(point):
		return
	active_pointer_type = pointer_type
	active_touch_index = touch_index
	touch_start = point
	last_touch_position = point
	gesture_axis = 0
	gesture_entry = _entry_at(point)
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
		var minimum_distance := maxf(72.0, minf(self.size.x * 0.12, 140.0))
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
	self.scroll_vertical -= roundi(finger_delta_y)


func _entry_at(point: Vector2) -> Control:
	for entry in entries.get_children():
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
		self.mouse_filter = Control.MOUSE_FILTER_STOP


func _cancel_touch_gesture() -> void:
	if gesture_axis == 1 and is_instance_valid(gesture_entry) and not gesture_entry.is_queued_for_deletion():
		gesture_entry.call("cancel_swipe")
	_reset_touch_gesture()


