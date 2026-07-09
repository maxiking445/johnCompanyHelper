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


func test_sovereign_region_uses_square_border_from_top_deck_event() -> void:
	var sovereign := _create_state(StateType.StateType.BOMBAY)
	sovereign.isSovereign = true
	var hyperbad := _create_state(StateType.StateType.HYPERBAD)
	_game_state.states = [sovereign, hyperbad]
	_set_top_deck_location(sovereign.location, EnumTypes.ElephantMarker.SQUARE)

	_rule.execute(_game_state)

	assert_true(_elephant.is_on_border())
	assert_eq(_elephant.get_backward_state(), sovereign.location)
	assert_eq(_elephant.get_facing_state(), hyperbad.location)


func test_sovereign_region_uses_triangle_border_from_top_deck_event() -> void:
	var sovereign := _create_state(StateType.StateType.BOMBAY)
	sovereign.isSovereign = true
	var punjab := _create_state(StateType.StateType.PUNJAB)
	_game_state.states = [sovereign, punjab]
	_set_top_deck_location(sovereign.location, EnumTypes.ElephantMarker.TRIANGLE)

	_rule.execute(_game_state)

	assert_true(_elephant.is_on_border())
	assert_eq(_elephant.get_backward_state(), sovereign.location)
	assert_eq(_elephant.get_facing_state(), punjab.location)


func test_madras_resolves_every_shape_to_expected_border() -> void:
	var madras := _create_state(StateType.StateType.MADRAS)
	madras.isSovereign = true
	var mysore := _create_state(StateType.StateType.MYSORE)
	var hyperbad := _create_state(StateType.StateType.HYPERBAD)
	_game_state.states = [madras, mysore, hyperbad]

	_assert_elephant_march_faces(
		madras.location,
		EnumTypes.ElephantMarker.SQUARE,
		mysore.location
	)
	_assert_elephant_march_faces(
		madras.location,
		EnumTypes.ElephantMarker.CIRCLE,
		hyperbad.location
	)
	_assert_elephant_march_faces(
		madras.location,
		EnumTypes.ElephantMarker.TRIANGLE,
		mysore.location
	)


func test_madras_square_and_triangle_share_the_same_border() -> void:
	var madras := _create_state(StateType.StateType.MADRAS)
	madras.isSovereign = true
	var mysore := _create_state(StateType.StateType.MYSORE)
	_game_state.states = [madras, mysore]

	_assert_elephant_march_faces(
		madras.location,
		EnumTypes.ElephantMarker.SQUARE,
		mysore.location
	)
	_assert_elephant_march_faces(
		madras.location,
		EnumTypes.ElephantMarker.TRIANGLE,
		mysore.location
	)


func test_active_event_shape_is_used_over_top_deck_shape() -> void:
	var sovereign := _create_state(StateType.StateType.BOMBAY)
	sovereign.isSovereign = true
	var hyperbad := _create_state(StateType.StateType.HYPERBAD)
	var maratha := _create_state(StateType.StateType.MARATHA)
	_game_state.states = [sovereign, hyperbad, maratha]
	_set_top_deck_location(sovereign.location, EnumTypes.ElephantMarker.SQUARE)
	EventHelper.activeEvent = _create_event(
		sovereign.location,
		EnumTypes.ElephantMarker.CIRCLE
	)

	_rule.execute(_game_state)

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


func test_sovereign_region_skips_multiple_own_dominated_neighbors_clockwise() -> void:
	var sovereign := _create_state(StateType.StateType.BOMBAY)
	sovereign.isSovereign = true
	sovereign.isEmpireCapital = true
	sovereign.partOfEmpire = EnumTypes.Empires.A
	var punjab := _create_state(StateType.StateType.PUNJAB)
	punjab.isDominated = true
	punjab.isDominatedBy = sovereign
	punjab.partOfEmpire = EnumTypes.Empires.A
	var hyperbad := _create_state(StateType.StateType.HYPERBAD)
	hyperbad.isDominated = true
	hyperbad.isDominatedBy = sovereign
	hyperbad.partOfEmpire = EnumTypes.Empires.A
	var maratha := _create_state(StateType.StateType.MARATHA)
	_game_state.states = [sovereign, punjab, hyperbad, maratha]
	_set_top_deck_location(sovereign.location, EnumTypes.ElephantMarker.TRIANGLE)

	_rule.execute(_game_state)

	assert_eq(_elephant.get_facing_state(), maratha.location)


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


func test_successful_invasion_crisis_target_overrides_top_deck_once() -> void:
	var capital := _create_state(StateType.StateType.BOMBAY)
	capital.isSovereign = true
	var march_target := _create_state(StateType.StateType.MARATHA)
	var top_deck_region := _create_state(StateType.StateType.BENGAL)
	top_deck_region.isCompanyControlled = true
	_game_state.states = [capital, march_target, top_deck_region]
	_game_state.hadASucessfullInvasionCrisis = true
	_game_state.sucessFullInvasionCapital = capital.location
	_set_top_deck_location(
		top_deck_region.location,
		EnumTypes.ElephantMarker.CIRCLE
	)

	_rule.execute(_game_state)

	assert_true(_elephant.is_on_border())
	assert_eq(_elephant.get_backward_state(), capital.location)
	assert_eq(_elephant.get_facing_state(), march_target.location)

	_rule.execute(_game_state)

	assert_true(_elephant.is_inside_state())
	assert_eq(_elephant.current_state, top_deck_region.location)


func _set_top_deck_location(
	location: StateType.StateType,
	elephant_shape: EnumTypes.ElephantMarker = EnumTypes.ElephantMarker.SQUARE
) -> void:
	var event := _create_event(location, elephant_shape)
	EventHelper.draw_pile = [event]


func _create_event(
	location: StateType.StateType,
	elephant_shape: EnumTypes.ElephantMarker = EnumTypes.ElephantMarker.SQUARE
) -> IndiaEvent:
	var event := IndiaEvent.new()
	event.eventLocation = location
	event.elephantShape = elephant_shape
	return event


func _assert_elephant_march_faces(
	location: StateType.StateType,
	elephant_shape: EnumTypes.ElephantMarker,
	expected_facing_location: StateType.StateType
) -> void:
	_set_top_deck_location(location, elephant_shape)

	_rule.execute(_game_state)

	assert_true(_elephant.is_on_border())
	assert_eq(_elephant.get_backward_state(), location)
	assert_eq(_elephant.get_facing_state(), expected_facing_location)


func _create_state(location: StateType.StateType) -> StateModel:
	var state := StateModel.new()
	state.location = location
	return state
