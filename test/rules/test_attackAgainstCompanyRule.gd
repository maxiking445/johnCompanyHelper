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
	var primary := _create_state(StateType.StateType.PUNJAB, 1, 5)
	var additional := _create_state(StateType.StateType.BENGAL, 2, 2)
	_game_state.states = [primary, additional]
	_set_event(2)

	_rule.execute_for_state(_game_state, primary)

	assert_eq(primary.exhaustedTroops, 3)
	assert_eq(additional.exhaustedTroops, 2)
	assert_eq(additional.unrest_size, 0)
	assert_eq(additional.trophyToken, 1)


func test_failed_defense_exhausts_all_available_troops_before_region_loss() -> void:
	var state := _create_state(StateType.StateType.PUNJAB, 3, 2)
	_game_state.states = [state]
	_set_event(1)

	_rule.execute_for_state(_game_state, state)

	assert_eq(state.exhaustedTroops, 2)
	assert_true(state.hasRebelled)


func _set_event(modifier: int) -> void:
	var event := IndiaEvent.new()
	event.modifier = modifier
	EventHelper.activeEvent = event


func _create_state(
	location: StateType.StateType,
	unrest: int,
	troops: int
) -> StateModel:
	var state := StateModel.new()
	state.location = location
	state.unrest_size = unrest
	state.troops = troops
	state.orders = []
	return state
