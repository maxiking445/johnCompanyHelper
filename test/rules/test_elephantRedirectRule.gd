extends GutTest

const ELEPHANT_REDIRECT_RULE := preload("res://rules/ElephantRedirectRule.gd")

var _rule: ElephantRedirectRule
var _game_state: TrackingGameState
var _state: StateModel


func before_each() -> void:
	_rule = ELEPHANT_REDIRECT_RULE.new()
	_game_state = TrackingGameState.new()
	_game_state.elephant = ElephantModel.new()
	_state = StateModel.new()
	_game_state.returned_state = _state



func test_execute_does_not_change_state_when_location_has_rebelled() -> void:
	_game_state.elephant.state = StateType.StateType.PUNJAB
	_state.location = StateType.StateType.PUNJAB
	_state.hasRebelled = true

	_rule.execute(_game_state)

	assert_true(_state.hasRebelled)
	assert_eq(_game_state.requested_locations, [StateType.StateType.PUNJAB])


func test_execute_does_not_change_state_when_location_has_not_rebelled() -> void:
	_game_state.elephant.state = StateType.StateType.BENGAL
	_state.location = StateType.StateType.BENGAL
	_state.hasRebelled = false

	_rule.execute(_game_state)

	assert_false(_state.hasRebelled)
	assert_eq(_game_state.requested_locations, [StateType.StateType.BENGAL])


class TrackingGameState:
	extends GameState

	var requested_locations: Array[StateType.StateType] = []
	var returned_state: StateModel

	func findStateByLocation(location: StateType.StateType) -> StateModel:
		requested_locations.append(location)
		return returned_state
