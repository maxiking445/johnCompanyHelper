extends GutTest

const LEADER_EVENT_RULE := preload("res://rules/events/LeaderEventRule.gd")

var _rule: LeaderEventRule
var _game_state: GameState


func before_each() -> void:
	_rule = LEADER_EVENT_RULE.new()
	_game_state = GameState.new()
	EventHelper.draw_pile = []
	EventHelper.discard_pile.clear()
	EventHelper.activeEvent = null


func after_each() -> void:
	EventHelper.draw_pile.clear()
	EventHelper.discard_pile.clear()
	EventHelper.activeEvent = null


func test_execute_adds_tower_level_when_event_location_is_sovereign() -> void:
	var state := _create_state(StateType.StateType.PUNJAB)
	state.isSovereign = true
	state.towerLevel = 2
	_game_state.states = [state]
	_set_leader_event(StateType.StateType.PUNJAB, 1)

	_rule.execute(_game_state)

	assert_eq(state.towerLevel, 3)
	assert_eq(state.unrest_size, 2)
	assert_eq(_game_state.bombay_presidency.army.exhausted_regiments, 0)


func test_execute_resolves_rebellion_when_event_location_is_not_sovereign() -> void:
	var state := _create_state(StateType.StateType.PUNJAB)
	state.isSovereign = false
	state.isCompanyControlled = true
	state.unrest_size = 2
	state.presidency = EnumTypes.Presidency.BOMBAY
	_game_state.bombay_presidency.army.regiments = 5
	_game_state.bombay_presidency.army.exhausted_regiments = 1
	_game_state.states = [state]
	_set_leader_event(StateType.StateType.PUNJAB, 1)

	_rule.execute(_game_state)

	assert_eq(_game_state.bombay_presidency.army.exhausted_regiments, 4)
	assert_eq(state.unrest_size, 0)


func test_execute_uses_normal_rebellion_for_dominated_region() -> void:
	var attacker := _create_state(StateType.StateType.PUNJAB)
	var defender := _create_state(StateType.StateType.DELHI)
	attacker.isDominated = true
	attacker.isDominatedBy = defender
	attacker.towerLevel = 3
	defender.towerLevel = 2
	_game_state.states = [attacker, defender]
	_set_leader_event(StateType.StateType.PUNJAB, 0)

	_rule.execute(_game_state)

	assert_true(attacker.isSovereign)
	assert_false(attacker.isDominated)
	assert_eq(attacker.unrest_size, 2)


func _set_leader_event(location: StateType.StateType, modifier: int) -> void:
	var event := IndiaEvent.new()
	event.eventLocation = location
	event.modifier = modifier
	EventHelper.draw_pile = [event]
	EventHelper.activeEvent = event


func _create_state(location: StateType.StateType) -> StateModel:
	var state := StateModel.new()
	state.location = location
	state.unrest_size = 2
	state.towerLevel = 1
	state.isSovereign = false
	return state
