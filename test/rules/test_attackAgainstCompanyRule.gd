extends GutTest

const ATTACK_RULE := preload("res://rules/AttackAgainstCompanyRule.gd")

var _rule: AttackAgainstCompanyRule
var _game_state: GameState


func before_each() -> void:
	_rule = ATTACK_RULE.new()
	_game_state = GameState.new()
	EventHelper.activeEvent = null
	ActionManager.clear()
	RollHelper.clearQueuedResults()


func after_each() -> void:
	EventHelper.activeEvent = null
	ActionManager.clear()
	RollHelper.clearQueuedResults()


func test_additional_rebellion_does_not_use_event_modifier() -> void:
	var primary := _create_state(StateType.StateType.PUNJAB, 1)
	var additional := _create_state(StateType.StateType.BENGAL, 2)
	primary.presidency = EnumTypes.Presidency.BOMBAY
	additional.presidency = EnumTypes.Presidency.BENGAL
	_game_state.bombay_presidency.army.regiments = 5
	_game_state.bengal_presidency.army.regiments = 2
	_game_state.states = [primary, additional]
	_set_event(2)

	_rule.execute_for_state(_game_state, primary)

	assert_eq(_game_state.bombay_presidency.army.exhausted_regiments, 3)
	assert_eq(_game_state.bengal_presidency.army.exhausted_regiments, 2)
	assert_eq(additional.unrest_size, 0)


func test_failed_defense_exhausts_all_available_army_before_region_loss() -> void:
	var state := _create_state(StateType.StateType.PUNJAB, 3)
	state.presidency = EnumTypes.Presidency.BOMBAY
	_game_state.bombay_presidency.army.regiments = 2
	_game_state.states = [state]
	_set_event(1)

	_rule.execute_for_state(_game_state, state)

	assert_eq(_game_state.bombay_presidency.army.exhausted_regiments, 2)
	assert_true(state.hasRebelled)


func test_two_regions_share_one_presidency_army() -> void:
	var primary := _create_state(StateType.StateType.PUNJAB, 2)
	var additional := _create_state(StateType.StateType.DELHI, 2)
	primary.presidency = EnumTypes.Presidency.BENGAL
	additional.presidency = EnumTypes.Presidency.BENGAL
	_game_state.bengal_presidency.army.regiments = 3
	_game_state.states = [primary, additional]
	_rule.execute_for_state(_game_state, primary, 0)
	assert_eq(_game_state.bengal_presidency.army.exhausted_regiments, 3)
	assert_false(primary.hasRebelled)
	assert_true(additional.hasRebelled)


func test_local_alliance_strength_defends_region_and_is_exhausted() -> void:
	var state := _create_state(StateType.StateType.BENGAL, 0)
	state.presidency = EnumTypes.Presidency.BENGAL
	var alliance := LocalAllianceModel.new()
	alliance.strength = 2
	_game_state.bengal_presidency.army.local_alliances.append(alliance)
	_game_state.states = [state]
	_rule.execute_for_state(_game_state, state, 2)
	assert_true(alliance.exhausted)
	assert_false(state.hasRebelled)


func test_exhausted_local_alliance_cannot_defend() -> void:
	var state := _create_state(StateType.StateType.BENGAL, 0)
	state.presidency = EnumTypes.Presidency.BENGAL
	var alliance := LocalAllianceModel.new()
	alliance.strength = 3
	alliance.exhausted = true
	_game_state.bengal_presidency.army.local_alliances.append(alliance)
	_game_state.states = [state]
	_rule.execute_for_state(_game_state, state, 1)
	assert_true(alliance.exhausted)
	assert_true(state.hasRebelled)


func test_additional_crises_use_presidency_order_even_for_home_regions() -> void:
	var primary := _create_state(StateType.StateType.DELHI, 0)
	primary.presidency = EnumTypes.Presidency.BENGAL
	var bengal := _create_state(StateType.StateType.BENGAL, 1)
	var madras := _create_state(StateType.StateType.MADRAS, 1)
	var bombay_region := _create_state(StateType.StateType.PUNJAB, 1)
	bombay_region.presidency = EnumTypes.Presidency.BOMBAY
	_game_state.states = [primary, bengal, madras, bombay_region]
	_game_state.bombay_presidency.army.regiments = 1
	_game_state.madras_presidency.army.regiments = 1
	_game_state.bengal_presidency.army.regiments = 2

	_rule.execute_for_state(_game_state, primary, 1)

	var battles := ActionManager.get_actions().filter(
		func(action: Action) -> bool: return action.title == "Battle Started"
	)
	assert_eq(battles.size(), 4)
	assert_true(battles[0].text.contains("Company in DELHI"))
	assert_true(battles[1].text.contains("Company in PUNJAB"))
	assert_true(battles[2].text.contains("Company in MADRAS"))
	assert_true(battles[3].text.contains("Company in BENGAL"))


func test_army_of_another_presidency_cannot_defend_region() -> void:
	var state := _create_state(StateType.StateType.PUNJAB, 0)
	state.presidency = EnumTypes.Presidency.BENGAL
	_game_state.states = [state]
	_game_state.bombay_presidency.army.regiments = 5

	_rule.execute_for_state(_game_state, state, 1)

	assert_true(state.hasRebelled)
	assert_eq(_game_state.bombay_presidency.army.exhausted_regiments, 0)


func test_previously_exhausted_pieces_cannot_defend_again() -> void:
	var state := _create_state(StateType.StateType.PUNJAB, 0)
	state.presidency = EnumTypes.Presidency.BOMBAY
	_game_state.states = [state]
	_game_state.bombay_presidency.army.regiments = 3
	_game_state.bombay_presidency.army.exhausted_regiments = 2

	_rule.execute_for_state(_game_state, state, 2)

	assert_true(state.hasRebelled)
	assert_eq(_game_state.bombay_presidency.army.exhausted_regiments, 3)


func test_alliance_strength_cannot_be_split_between_two_regions() -> void:
	var primary := _create_state(StateType.StateType.BENGAL, 0)
	var additional := _create_state(StateType.StateType.DELHI, 1)
	additional.presidency = EnumTypes.Presidency.BENGAL
	_game_state.states = [primary, additional]
	var alliance := LocalAllianceModel.new()
	alliance.strength = 3
	_game_state.bengal_presidency.army.local_alliances.append(alliance)

	_rule.execute_for_state(_game_state, primary, 2)

	assert_true(alliance.exhausted)
	assert_false(primary.hasRebelled)
	assert_true(additional.hasRebelled)


func test_region_loss_example_exhausts_whole_army_including_alliance() -> void:
	var state := _create_state(StateType.StateType.BENGAL, 3)
	_game_state.states = [state]
	var army := _game_state.bengal_presidency.army
	army.officers = 2
	army.regiments = 2
	var alliance := LocalAllianceModel.new()
	alliance.strength = 2
	army.local_alliances.append(alliance)
	RollHelper.d6_results = [1, 1]

	_rule.execute_for_state(_game_state, state, 5)

	assert_true(state.hasRebelled)
	assert_eq(army.exhausted_officers, 2)
	assert_eq(army.exhausted_regiments, 2)
	assert_true(alliance.exhausted)
	assert_eq(army.officers, 2)


func test_vacant_commander_does_not_receive_trophy_for_defense() -> void:
	var state := _create_state(StateType.StateType.BOMBAY, 0)
	_game_state.states = [state]
	_game_state.bombay_presidency.army.regiments = 1

	_rule.execute_for_state(_game_state, state, 1)

	assert_false(state.hasRebelled)
	assert_eq(_action_count("Add Trophy"), 0)


func test_commander_receives_trophy_for_successful_defense() -> void:
	var state := _create_state(StateType.StateType.BOMBAY, 0)
	_game_state.states = [state]
	_game_state.bombay_presidency.has_commander = true
	_game_state.bombay_presidency.army.regiments = 1

	_rule.execute_for_state(_game_state, state, 1)

	assert_eq(_action_count("Add Trophy"), 1)


func _action_count(title: String) -> int:
	return ActionManager.get_actions().filter(
		func(action: Action) -> bool: return action.title == title
	).size()


func _set_event(modifier: int) -> void:
	var event := IndiaEvent.new()
	event.modifier = modifier
	EventHelper.activeEvent = event


func _create_state(
	location: StateType.StateType,
	unrest: int
) -> StateModel:
	var state := StateModel.new()
	state.location = location
	state.unrest_size = unrest
	state.isCompanyControlled = true
	state.orders = []
	return state
