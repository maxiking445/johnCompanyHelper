extends GutTest

const MAIN := preload("res://scenes/main.gd")


func assert_scenario(scenario: MainGameIntegrationScenario) -> void:
	assert_not_null(scenario, "Integration scenario")
	if scenario == null:
		return

	var scenario_name := scenario.scenario_name
	if scenario_name.is_empty():
		scenario_name = scenario.resource_path.get_base_dir().get_file()
	assert_not_null(scenario.start_game_state, "%s: start GameState" % scenario_name)
	assert_not_null(scenario.expected_game_state, "%s: expected GameState" % scenario_name)
	assert_gt(scenario.event_deck.size(), 0, "%s: event deck" % scenario_name)
	assert_not_null(scenario.location_event, "%s: final location event" % scenario_name)
	if (
		scenario.start_game_state == null
		or scenario.expected_game_state == null
		or scenario.event_deck.is_empty()
		or scenario.location_event == null
	):
		return
	for event in scenario.event_deck:
		assert_not_null(event, "%s: event reference" % scenario_name)

	var executable_event_count := scenario.event_deck.size()
	var runtime_event_deck := scenario.event_deck.duplicate()
	runtime_event_deck.append(scenario.location_event)

	var main = autofree(MAIN.new())
	var result: GameState = main.start_test_game(
		scenario.start_game_state,
		runtime_event_deck,
		executable_event_count,
		scenario.d6_results,
		scenario.storm_dice_results
	)

	_assert_game_states_equal(result, scenario.expected_game_state, scenario_name)
	assert_eq(
		EventHelper.draw_pile.size(),
		scenario.expected_remaining_event_count,
		"%s: remaining event count" % scenario_name
	)


func after_each() -> void:
	EventHelper.draw_pile.clear()
	EventHelper.discard_pile.clear()
	EventHelper.activeEvent = null
	RollHelper.clearQueuedResults()


func _assert_game_states_equal(
	actual: GameState,
	expected: GameState,
	scenario_name: String
) -> void:
	assert_not_null(actual, "%s: resulting GameState" % scenario_name)
	assert_eq(actual.companyStanding, expected.companyStanding, "%s: Company Standing" % scenario_name)
	assert_eq(actual.eventsToDraw, expected.eventsToDraw, "%s: events to draw" % scenario_name)
	_assert_elephants_equal(actual.elephant, expected.elephant, scenario_name)
	_assert_seas_equal(actual.seaWest, expected.seaWest, "%s: West sea" % scenario_name)
	_assert_seas_equal(actual.seaEast, expected.seaEast, "%s: East sea" % scenario_name)
	_assert_seas_equal(actual.seaSouth, expected.seaSouth, "%s: South sea" % scenario_name)

	var actual_states := actual.getStates().filter(func(state): return state != null)
	var expected_states := expected.getStates().filter(func(state): return state != null)
	assert_eq(actual_states.size(), expected_states.size(), "%s: state count" % scenario_name)
	for expected_state in expected_states:
		var actual_state := actual.findStateByLocation(expected_state.location)
		assert_not_null(actual_state, "%s: missing state %s" % [scenario_name, expected_state.location])
		_assert_states_equal(actual_state, expected_state, scenario_name)


func _assert_states_equal(
	actual: StateModel,
	expected: StateModel,
	scenario_name: String
) -> void:
	var fields := [
		"location", "writers", "unrest_size", "hasCommander", "officers",
		"troops", "exhaustedTroops", "hasGovenor", "treasury_size",
		"is_connected_to", "isSovereign", "partOfEmpire", "isEmpireCapital",
		"isDominated", "isCompanyControlled", "towerLevel", "trophyToken",
		"hasRebelled",
	]
	for field in fields:
		assert_eq(
			actual.get(field),
			expected.get(field),
			"%s: state %s.%s" % [scenario_name, expected.location, field]
		)

	var actual_dominator = actual.isDominatedBy.location if actual.isDominatedBy else null
	var expected_dominator = expected.isDominatedBy.location if expected.isDominatedBy else null
	assert_eq(actual_dominator, expected_dominator, "%s: dominating state" % scenario_name)
	assert_eq(actual.orders.size(), expected.orders.size(), "%s: order count" % scenario_name)
	for index in expected.orders.size():
		var order_label := "%s: state %s order %s" % [scenario_name, expected.location, index]
		assert_eq(actual.orders[index].orderState, expected.orders[index].orderState, "%s state" % order_label)
		assert_eq(actual.orders[index].value, expected.orders[index].value, "%s value" % order_label)
		assert_eq(actual.orders[index].state, expected.orders[index].state, "%s location" % order_label)


func _assert_elephants_equal(
	actual: ElephantModel,
	expected: ElephantModel,
	scenario_name: String
) -> void:
	if expected == null:
		assert_null(actual, "%s: Elephant" % scenario_name)
		return
	assert_not_null(actual, "%s: Elephant" % scenario_name)
	assert_eq(actual.placement, expected.placement, "%s: Elephant placement" % scenario_name)
	assert_eq(actual.current_state, expected.current_state, "%s: Elephant region" % scenario_name)
	assert_eq(actual.border_state_a, expected.border_state_a, "%s: Elephant border A" % scenario_name)
	assert_eq(actual.border_state_b, expected.border_state_b, "%s: Elephant border B" % scenario_name)
	assert_eq(actual.facing_state, expected.facing_state, "%s: Elephant facing" % scenario_name)


func _assert_seas_equal(actual: SeaModel, expected: SeaModel, label: String) -> void:
	if expected == null:
		assert_null(actual, label)
		return
	assert_not_null(actual, label)
	assert_eq(actual.ships.size(), expected.ships.size(), "%s ship count" % label)
	for index in expected.ships.size():
		assert_eq(actual.ships[index].shipType, expected.ships[index].shipType)
		assert_eq(actual.ships[index].shipOwner, expected.ships[index].shipOwner)
		assert_eq(actual.ships[index].isFlipped, expected.ships[index].isFlipped)
