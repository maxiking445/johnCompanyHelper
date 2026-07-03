extends GutTest

const REBELLION_RULE := preload("res://rules/RebellionRule.gd")

var _rule: RebellionRule
var _game_state: GameState
var _attacker: StateModel
var _defender: StateModel


func before_each() -> void:
	_rule = REBELLION_RULE.new()
	_game_state = GameState.new()
	_attacker = _create_state(StateType.StateType.MYSORE, 2)
	_defender = _create_state(StateType.StateType.MADRAS, 2)
	_attacker.isDominated = true
	_attacker.isDominatedBy = _defender
	_attacker.partOfEmpire = EnumTypes.Empires.A
	_game_state.states = [_attacker, _defender]

	var event := IndiaEvent.new()
	event.modifier = 1
	EventHelper.activeEvent = event


func after_each() -> void:
	EventHelper.activeEvent = null


func test_success_makes_attacker_sovereign_and_closes_orders() -> void:
	var order := OrderModel.new()
	order.state = _attacker.location
	order.open()
	_attacker.orders = [order]

	_rule.execute_detail(_game_state, _attacker, _defender)

	assert_true(_attacker.isSovereign)
	assert_false(_attacker.isDominated)
	assert_null(_attacker.isDominatedBy)
	assert_eq(_attacker.partOfEmpire, EnumTypes.Empires.NONE)
	assert_true(order.isClosed())
	assert_eq(_defender.towerLevel, 2)


func test_tied_strength_fails_and_removes_defender_tower_level() -> void:
	_attacker.towerLevel = 1

	_rule.execute_detail(_game_state, _attacker, _defender)

	assert_false(_attacker.isSovereign)
	assert_true(_attacker.isDominated)
	assert_eq(_defender.towerLevel, 1)


func _create_state(location: StateType.StateType, tower_level: int) -> StateModel:
	var state := StateModel.new()
	state.location = location
	state.towerLevel = tower_level
	state.orders = []
	return state
