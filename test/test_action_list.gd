extends GutTest


func test_vertical_touch_scroll_and_horizontal_mouse_dismiss() -> void:
	var list := preload("res://scenes/component/ActionList.tscn").instantiate()
	add_child_autofree(list)
	list.position = Vector2(100, 100)
	list.size = Vector2(700, 300)
	var actions: Array[Action] = []
	for index in range(10):
		var action := FormattedAction.new()
		action.title = "Ship %d" % index
		action.text = "Flip this ship to its fatigued side."
		actions.append(action)
	list.display_actions(actions)
	await get_tree().process_frame
	await get_tree().process_frame
	var point: Vector2 = list.global_position + Vector2(300, 200)
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.position = point
	touch.pressed = true
	list._input(touch)
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = point - Vector2(0, 120)
	list._input(drag)
	touch.position = drag.position
	touch.pressed = false
	list._input(touch)
	assert_gt(list.scroll_vertical, 0)
	assert_eq(list.entries.get_child_count(), 10, "Vertical drag must not dismiss actions")
	await get_tree().create_timer(0.35).timeout
	point = list.global_position + Vector2(300, 120)
	var mouse := InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.position = point
	mouse.pressed = true
	list._input(mouse)
	var motion := InputEventMouseMotion.new()
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	motion.position = point - Vector2(200, 0)
	list._input(motion)
	mouse.position = motion.position
	mouse.pressed = false
	list._input(mouse)
	await get_tree().create_timer(0.3).timeout
	assert_eq(list.entries.get_child_count(), 9, "Mouse swipe dismisses only its action")
