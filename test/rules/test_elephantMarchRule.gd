extends GutTest

const ELEPHANT_MARCH_RULE := preload("res://rules/ElephantMarchRule.gd")

var _rule: ElephantMarchRule
var _game_state: GameState
var _elephant: ElephantModel


func before_each() -> void:
	_rule = ELEPHANT_MARCH_RULE.new()
	_game_state = GameState.new()
	_elephant = ElephantModel.new()
	_game_state.elephant = _elephant
	EventHelper.draw_pile = []


func after_each() -> void:
	EventHelper.draw_pile.clear()


func test_company_region_places_elephant_inside_region() -> void:
	var state := _create_state(StateType.StateType.BOMBAY)
	state.isCompanyControlled = true
	_game_state.states = [state]
	_set_top_deck_location(state.location)

	_rule.execute(_game_state)

	assert_true(_elephant.is_inside_state())
	assert_eq(_elephant.current_state, state.location)


func test_dominated_region_places_elephant_on_border_facing_dominator() -> void:
	var dominated := _create_state(StateType.StateType.MYSORE)
	var dominator := _create_state(StateType.StateType.MADRAS)
	dominated.isDominated = true
	dominated.isDominatedBy = dominator
	_game_state.states = [dominated, dominator]
	_set_top_deck_location(dominated.location)

	_rule.execute(_game_state)

	assert_true(_elephant.is_on_border())
	assert_eq(_elephant.get_backward_state(), dominated.location)
	assert_eq(_elephant.get_facing_state(), dominator.location)


func _set_top_deck_location(location: StateType.StateType) -> void:
	var event := IndiaEvent.new()
	event.eventLocation = location
	EventHelper.draw_pile = [event]


func _create_state(location: StateType.StateType) -> StateModel:
	var state := StateModel.new()
	state.location = location
	return state
