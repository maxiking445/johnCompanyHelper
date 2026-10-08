extends GutTest

const ATTACK_RULE := preload("res://rules/AttackAgainstCompanyRule.gd")

var _rule: AttackAgainstCompanyRule
var _game_state: GameState


func before_each() -> void:
	_rule = ATTACK_RULE.new()
	_game_state = GameState.new()
	EventHelper.activeEvent = null


func after_each() -> void:
	EventHelper.activeEvent = null


func test_additional_rebellion_does_not_use_event_modifier() -> void:
	var primary := _create_state(StateType.StateType.PUNJAB, 1)
	var additional := _create_state(StateType.StateType.BENGAL, 2)
	primary.presidency = 1
	additional.presidency = 3
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
	state.presidency = 1
	_game_state.bombay_presidency.army.regiments = 2
	_game_state.states = [state]
	_set_event(1)

	_rule.execute_for_state(_game_state, state)

	assert_eq(_game_state.bombay_presidency.army.exhausted_regiments, 2)
	assert_true(state.hasRebelled)


func test_two_regions_share_one_presidency_army() -> void:
	var primary := _create_state(StateType.StateType.PUNJAB, 2)
	var additional := _create_state(StateType.StateType.DELHI, 2)
	primary.presidency = 3
	additional.presidency = 3
	_game_state.bengal_presidency.army.regiments = 3
	_game_state.states = [primary, additional]
	_rule.execute_for_state(_game_state, primary, 0)
	assert_eq(_game_state.bengal_presidency.army.exhausted_regiments, 3)
	assert_false(primary.hasRebelled)
	assert_true(additional.hasRebelled)


func test_local_alliance_strength_defends_region_and_is_exhausted() -> void:
	var state := _create_state(StateType.StateType.BENGAL, 0)
	state.presidency = 3
	var alliance := LocalAllianceModel.new()
	alliance.strength = 2
	alliance.purchased = true
	_game_state.bengal_presidency.army.local_alliances.append(alliance)
	_game_state.states = [state]
	_rule.execute_for_state(_game_state, state, 2)
	assert_true(alliance.exhausted)
	assert_false(state.hasRebelled)


func test_unpurchased_local_alliance_cannot_defend() -> void:
	var state := _create_state(StateType.StateType.BENGAL, 0)
	state.presidency = 3
	var alliance := LocalAllianceModel.new()
	alliance.strength = 3
	_game_state.bengal_presidency.army.local_alliances.append(alliance)
	_game_state.states = [state]
	_rule.execute_for_state(_game_state, state, 1)
	assert_false(alliance.exhausted)
	assert_true(state.hasRebelled)


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
