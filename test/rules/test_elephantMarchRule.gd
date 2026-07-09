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
	EventHelper.activeEvent = null


func after_each() -> void:
	EventHelper.draw_pile.clear()
	EventHelper.activeEvent = null


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


func test_sovereign_region_uses_border_selected_by_event_shape() -> void:
	var sovereign := _create_state(StateType.StateType.BOMBAY)
	sovereign.isSovereign = true
	sovereign.is_connected_to = [
		StateType.StateType.PUNJAB,
		StateType.StateType.MARATHA,
	]
	var punjab := _create_state(StateType.StateType.PUNJAB)
	var maratha := _create_state(StateType.StateType.MARATHA)
	_game_state.states = [sovereign, punjab, maratha]
	_set_top_deck_location(sovereign.location, EnumTypes.ElephantMarker.CIRCLE)

	_rule.execute(_game_state)

	assert_true(_elephant.is_on_border())
	assert_eq(_elephant.get_backward_state(), sovereign.location)
	assert_eq(_elephant.get_facing_state(), maratha.location)


func test_sovereign_region_skips_own_dominated_neighbor_clockwise() -> void:
	var sovereign := _create_state(StateType.StateType.BOMBAY)
	sovereign.isSovereign = true
	sovereign.isEmpireCapital = true
	sovereign.partOfEmpire = EnumTypes.Empires.A
	sovereign.is_connected_to = [
		StateType.StateType.PUNJAB,
		StateType.StateType.MARATHA,
	]
	var punjab := _create_state(StateType.StateType.PUNJAB)
	punjab.isDominated = true
	punjab.isDominatedBy = sovereign
	punjab.partOfEmpire = EnumTypes.Empires.A
	var hyperbad := _create_state(StateType.StateType.HYPERBAD)
	_game_state.states = [sovereign, punjab, hyperbad]
	_set_top_deck_location(sovereign.location, EnumTypes.ElephantMarker.TRIANGLE)

	_rule.execute(_game_state)

	assert_eq(_elephant.get_facing_state(), hyperbad.location)


func test_fully_formed_empire_redirects_elephant_to_capital() -> void:
	var sovereign := _create_state(StateType.StateType.BOMBAY)
	sovereign.isSovereign = true
	sovereign.isEmpireCapital = true
	sovereign.partOfEmpire = EnumTypes.Empires.A
	sovereign.is_connected_to = [
		StateType.StateType.HYPERBAD,
		StateType.StateType.PUNJAB,
		StateType.StateType.MARATHA,
	]
	var hyperbad := _create_state(StateType.StateType.HYPERBAD)
	hyperbad.isDominated = true
	hyperbad.isDominatedBy = sovereign
	hyperbad.partOfEmpire = EnumTypes.Empires.A
	var dominated := _create_state(StateType.StateType.PUNJAB)
	dominated.isDominated = true
	dominated.isDominatedBy = sovereign
	dominated.partOfEmpire = EnumTypes.Empires.A
	var maratha := _create_state(StateType.StateType.MARATHA)
	maratha.isDominated = true
	maratha.isDominatedBy = sovereign
	maratha.partOfEmpire = EnumTypes.Empires.A
	_game_state.states = [sovereign, hyperbad, dominated, maratha]
	_set_top_deck_location(sovereign.location, EnumTypes.ElephantMarker.CIRCLE)

	_rule.execute(_game_state)

	assert_eq(_elephant.get_backward_state(), maratha.location)
	assert_eq(_elephant.get_facing_state(), sovereign.location)


func _set_top_deck_location(
	location: StateType.StateType,
	elephant_shape: EnumTypes.ElephantMarker = EnumTypes.ElephantMarker.SQUARE
) -> void:
	var event := IndiaEvent.new()
	event.eventLocation = location
	event.elephantShape = elephant_shape
	EventHelper.draw_pile = [event]


func _create_state(location: StateType.StateType) -> StateModel:
	var state := StateModel.new()
	state.location = location
	return state
