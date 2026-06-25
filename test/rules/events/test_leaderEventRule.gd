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
	assert_eq(state.exhaustedTroops, 0)


func test_execute_resolves_rebellion_when_event_location_is_not_sovereign() -> void:
	var state := _create_state(StateType.StateType.PUNJAB)
	state.isSovereign = false
	state.unrest_size = 2
	state.troops = 5
	state.exhaustedTroops = 1
	_game_state.states = [state]
	_set_leader_event(StateType.StateType.PUNJAB, 1)

	_rule.execute(_game_state)

	assert_eq(state.exhaustedTroops, 4)
	assert_eq(state.unrest_size, 0)
	assert_eq(state.trophyToken, 1)


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
	state.troops = 5
	state.exhaustedTroops = 0
	state.towerLevel = 1
	state.trophyToken = 0
	state.isSovereign = false
	return state
