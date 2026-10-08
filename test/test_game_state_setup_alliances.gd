extends GutTest

const SETUP_SCENE := preload("res://UI/GameStateSetup/GameStateSetup.tscn")
const SECTION_SCRIPT := preload("res://UI/GameStateSetup/components/ShipSeaSection.gd")
const GAME_STATE_1710 := preload("res://resources/gameState/GameState1710.tres")


func test_add_alliance_from_1710_presidency_step() -> void:
	var setup: GameStateSetup = SETUP_SCENE.instantiate()
	add_child(setup)
	setup.game_state = GAME_STATE_1710.duplicate(true)
	setup.current_step = 8
	setup._show_step()
	await get_tree().process_frame
	var section := _find_alliance_section(setup)
	assert_not_null(section)
	var count_field := _find_alliance_count_field(setup)
	assert_not_null(count_field)
	(count_field.get_node("PlusButton") as Button).pressed.emit()
	await get_tree().process_frame
	assert_eq(setup.game_state.bombay_presidency.army.local_alliances.size(), 1)
	var card := _find_alliance_card(setup)
	assert_not_null(card)
	var field_names: Array[String] = []
	for field in (card.get("content") as VBoxContainer).get_children():
		if field.has_method("get_field_slot"):
			field_names.append(field.active_label.text)
	assert_true(field_names.has("Strength"))
	assert_true(field_names.has("Exhausted"))
	assert_false(field_names.has("Name"))
	assert_false(field_names.has("Purchased"))
	var exhausted_checkbox := _find_exhausted_checkbox(card)
	assert_not_null(exhausted_checkbox)
	exhausted_checkbox.button_pressed = true
	assert_true(setup.game_state.bombay_presidency.army.local_alliances[0].exhausted)
	exhausted_checkbox.button_pressed = false
	assert_false(setup.game_state.bombay_presidency.army.local_alliances[0].exhausted)
	count_field = _find_alliance_count_field(setup)
	(count_field.get_node("MinusButton") as Button).pressed.emit()
	await get_tree().process_frame
	assert_eq(setup.game_state.bombay_presidency.army.local_alliances.size(), 0)
	setup.free()


func _find_alliance_section(setup: GameStateSetup) -> Node:
	for child in setup.form.get_children():
		if child.get_script() == SECTION_SCRIPT and not child.is_queued_for_deletion():
			return child
	return null


func _find_alliance_card(setup: GameStateSetup) -> Node:
	for child in setup.form.get_children():
		if child.get_script() == preload("res://UI/GameStateSetup/components/ResourceCard.gd") and not child.is_queued_for_deletion():
			return child
	return null


func _find_alliance_count_field(setup: GameStateSetup) -> Node:
	for child in setup.form.get_children():
		if child.get_script() == preload("res://UI/GameStateSetup/components/NumberStepper.gd") and not child.is_queued_for_deletion():
			return child
	return null


func _find_exhausted_checkbox(card: Node) -> CheckBox:
	for field in (card.get("content") as VBoxContainer).get_children():
		if field.has_method("get_field_slot") and field.active_label.text == "Exhausted":
			var slot: Control = field.call("get_field_slot")
			return slot.get_child(0).get_node("CheckBox") as CheckBox
	return null
