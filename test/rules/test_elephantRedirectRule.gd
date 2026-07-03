extends GutTest

const ELEPHANT_REDIRECT_RULE := preload("res://rules/ElephantRedirectRule.gd")

var _rule: ElephantRedirectRule
var _game_state: GameState
var _rebelled_state: StateModel


func before_each() -> void:
	_rule = ELEPHANT_REDIRECT_RULE.new()
	_game_state = GameState.new()
	_game_state.elephant = ElephantModel.new()
	_rebelled_state = _create_state(StateType.StateType.PUNJAB)
	_game_state.states = [_rebelled_state]
	EventHelper.draw_pile = []


func after_each() -> void:
	EventHelper.draw_pile.clear()


func test_rebelled_elephant_region_performs_elephant_march() -> void:
	var destination := _create_state(StateType.StateType.BENGAL)
	destination.isCompanyControlled = true
	_game_state.states.append(destination)
	_game_state.elephant.placeInCenterOf(_rebelled_state.location)
	_rebelled_state.hasRebelled = true
	_set_top_deck_location(destination.location)

	_rule.execute(_game_state)

	assert_true(_game_state.elephant.is_inside_state())
	assert_eq(_game_state.elephant.current_state, destination.location)
	assert_false(_rebelled_state.hasRebelled)


func test_region_without_successful_rebellion_does_not_move_elephant() -> void:
	_game_state.elephant.placeInCenterOf(_rebelled_state.location)
	_rebelled_state.hasRebelled = false

	_rule.execute(_game_state)

	assert_eq(_game_state.elephant.current_state, _rebelled_state.location)


func test_elephant_on_border_is_not_redirected() -> void:
	_game_state.elephant.placeOnBorderOf(
		StateType.StateType.BENGAL,
		StateType.StateType.PUNJAB
	)
	_rebelled_state.hasRebelled = true

	_rule.execute(_game_state)

	assert_true(_game_state.elephant.is_on_border())
	assert_eq(
		_game_state.elephant.get_facing_state(),
		StateType.StateType.BENGAL
	)


func test_foreign_invasion_redirect_uses_circle_and_restores_tile_shape() -> void:
	var destination := _create_state(StateType.StateType.BOMBAY)
	destination.isSovereign = true
	destination.is_connected_to = [
		StateType.StateType.PUNJAB,
		StateType.StateType.MARATHA,
	]
	var punjab := _create_state(StateType.StateType.PUNJAB)
	var maratha := _create_state(StateType.StateType.MARATHA)
	_game_state.states.append_array([destination, punjab, maratha])
	_game_state.elephant.placeInCenterOf(_rebelled_state.location)
	_rebelled_state.hasRebelled = true
	var event := _set_top_deck_location(destination.location)
	event.elephantBorderIndex = 1

	_rule.execute_with_circle_shape(_game_state)

	assert_eq(_game_state.elephant.get_facing_state(), punjab.location)
	assert_eq(event.elephantBorderIndex, 1)


func _set_top_deck_location(location: StateType.StateType) -> IndiaEvent:
	var event := IndiaEvent.new()
	event.eventLocation = location
	EventHelper.draw_pile = [event]
	return event


func _create_state(location: StateType.StateType) -> StateModel:
	var state := StateModel.new()
	state.location = location
	return state
