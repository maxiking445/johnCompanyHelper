extends GutTest

const LOOSE_REGION_RULE := preload("res://rules/LooseRegionRule.gd")

var _rule: LooseRegionRule
var _game_state: GameState


func before_each() -> void:
	_rule = LOOSE_REGION_RULE.new()
	_game_state = GameState.new()


func test_execute_for_state_resets_region_and_tracks_region_loss() -> void:
	var state := _create_state(StateType.StateType.BOMBAY)
	state.unrest_size = 3
	state.towerLevel = 4
	_game_state.states = [state]

	_rule.execute_for_state(_game_state, state)

	assert_eq(state.unrest_size, 0)
	assert_eq(state.towerLevel, 1)
	assert_eq(_rule.lostRegionsThisRound, 1)


func test_execute_for_location_finds_state_before_losing_region() -> void:
	var bombay := _create_state(StateType.StateType.BOMBAY)
	var madras := _create_state(StateType.StateType.MADRAS)
	madras.unrest_size = 2
	madras.towerLevel = 3
	_game_state.states = [bombay, madras]

	_rule.execute_for_location(_game_state, StateType.StateType.MADRAS)

	assert_eq(bombay.towerLevel, 2)
	assert_eq(madras.unrest_size, 0)
	assert_eq(madras.towerLevel, 1)


func test_reset_lost_regions_this_round_restarts_loss_count() -> void:
	var first_state := _create_state(StateType.StateType.BOMBAY)
	var second_state := _create_state(StateType.StateType.MADRAS)
	_game_state.states = [first_state, second_state]

	_rule.execute_for_state(_game_state, first_state)
	_rule.execute_for_state(_game_state, second_state)

	_rule.reset_lost_regions_this_round()
	_rule.execute_for_state(_game_state, first_state)

	assert_eq(_rule.lostRegionsThisRound, 1)


func test_officer_rout_uses_associated_presidency_army() -> void:
	var state := _create_state(StateType.StateType.PUNJAB)
	state.presidency = EnumTypes.Presidency.BENGAL
	_game_state.states = [state]
	_game_state.bengal_presidency.army.officers = 2
	RollHelper.d6_results = [6, 1]
	_rule.execute_for_state(_game_state, state)
	assert_eq(_game_state.bengal_presidency.army.officers, 1)
	RollHelper.clearQueuedResults()


func _create_state(location: StateType.StateType) -> StateModel:
	var state := StateModel.new()
	state.location = location
	state.unrest_size = 1
	state.towerLevel = 2
	state.presidency = (
		EnumTypes.Presidency.BOMBAY
		if location == StateType.StateType.BOMBAY
		else EnumTypes.Presidency.MADRAS
	)
	state.hasGovernor = false
	return state
