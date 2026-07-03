extends GutTest

const INVASION_RULE := preload("res://rules/InvasionRule.gd")

var _rule: InvasionRule
var _game_state: GameState


func before_each() -> void:
	_rule = INVASION_RULE.new()
	_game_state = GameState.new()
	var event := IndiaEvent.new()
	event.modifier = 0
	EventHelper.activeEvent = event


func after_each() -> void:
	EventHelper.activeEvent = null


func test_stronger_sovereign_attacker_creates_new_empire() -> void:
	var attacker := _create_state(StateType.StateType.PUNJAB, 3)
	var defender := _create_state(StateType.StateType.DELIH, 2)
	attacker.isSovereign = true
	defender.isSovereign = true
	_game_state.states = [attacker, defender]

	_rule.execute_detail(_game_state, attacker, defender)

	assert_eq(attacker.partOfEmpire, EnumTypes.Empires.A)
	assert_true(attacker.isSovereignCapital)
	assert_eq(defender.partOfEmpire, EnumTypes.Empires.A)
	assert_true(defender.isDominated)
	assert_eq(defender.isDominatedBy, attacker)


func test_tied_invasion_fails_and_removes_attacker_tower() -> void:
	var attacker := _create_state(StateType.StateType.PUNJAB, 2)
	var defender := _create_state(StateType.StateType.DELIH, 2)
	attacker.isSovereign = true
	defender.isSovereign = true
	_game_state.states = [attacker, defender]

	_rule.execute_detail(_game_state, attacker, defender)

	assert_eq(attacker.towerLevel, 1)
	assert_eq(defender.partOfEmpire, EnumTypes.Empires.NONE)
	assert_false(defender.isDominated)


func test_invasion_strength_includes_all_regions_in_attacker_empire() -> void:
	var attacker := _create_state(StateType.StateType.PUNJAB, 2)
	var ally := _create_state(StateType.StateType.BENGAL, 2)
	attacker.partOfEmpire = EnumTypes.Empires.A
	ally.partOfEmpire = EnumTypes.Empires.A
	_game_state.states = [attacker, ally]

	assert_eq(_rule.calculate_attack_strength(_game_state, attacker), 4)


func _create_state(
	location: StateType.StateType,
	tower_level: int
) -> StateModel:
	var state := StateModel.new()
	state.location = location
	state.towerLevel = tower_level
	state.orders = []
	return state
