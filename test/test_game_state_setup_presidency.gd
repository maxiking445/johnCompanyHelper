extends GutTest

const SETUP_SCENE := preload("res://UI/GameStateSetup/GameStateSetup.tscn")

var setup: GameStateSetup


func before_each() -> void:
	setup = SETUP_SCENE.instantiate()
	add_child(setup)
	for child in setup.form.get_children():
		child.free()
	setup.game_state = GameState.new()


func after_each() -> void:
	setup.free()


func test_home_region_hides_presidency_but_keeps_governor_editable() -> void:
	var state := StateModel.new()
	state.location = StateType.StateType.MADRAS
	setup._add_resource_editor(state, false)
	var fields := _field_names()
	assert_false(fields.has("Presidency"))
	assert_true(fields.has("Has Governor"))


func test_acquired_region_shows_associated_presidency() -> void:
	var state := StateModel.new()
	state.location = StateType.StateType.MYSORE
	state.isCompanyControlled = true
	setup._add_resource_editor(state, false)
	assert_true(_field_names().has("Presidency"))


func test_unconquered_region_starts_with_none_and_can_edit_presidency() -> void:
	for location in [
		StateType.StateType.HYDERABAD,
		StateType.StateType.PUNJAB,
		StateType.StateType.MARATHA,
		StateType.StateType.DELHI,
		StateType.StateType.MYSORE,
	]:
		for child in setup.form.get_children():
			child.free()
		var state := StateModel.new()
		state.location = location
		setup._add_resource_editor(state, false)
		assert_eq(state.presidency, EnumTypes.Presidency.NONE)
		assert_true(_field_names().has("Presidency"))


func _field_names() -> Array[String]:
	var names: Array[String] = []
	for child in setup.form.get_children():
		if child.has_method("get_field_slot"):
			names.append(child.active_label.text)
	return names
