extends GutTest

const GAME_STATE_1710 := preload("res://resources/gameState/GameState1710.tres")
const GAME_STATE_1758 := preload("res://resources/gameState/GameState1758.tres")
const GAME_STATE_1813 := preload("res://resources/gameState/GameState1813.tres")
const SINGLE_CRISIS := preload("res://test/integration/scenarios/single_crisis/StartGameState.tres")


func test_all_default_game_states_are_complete() -> void:
	for game_state in [GAME_STATE_1710, GAME_STATE_1758, GAME_STATE_1813]:
		assert_eq(game_state.getStates().size(), 8)
		assert_not_null(game_state.elephant)
		assert_not_null(game_state.seaWest)
		assert_not_null(game_state.seaEast)
		assert_not_null(game_state.seaSouth)


func test_1758_matches_company_under_siege_india_setup() -> void:
	assert_true(GAME_STATE_1758.bengal.isCompanyControlled)
	assert_true(GAME_STATE_1758.bengal.hasGovernor)
	assert_eq(GAME_STATE_1758.bombay.towerLevel, 2)
	assert_eq(GAME_STATE_1758.maratha.towerLevel, 2)
	assert_eq(GAME_STATE_1758.madras.towerLevel, 2)
	assert_eq(GAME_STATE_1758.seaEast.ships.size(), 1)
	assert_true(GAME_STATE_1758.seaEast.ships[0].isCompanyShip())


func test_1813_matches_post_monopoly_india_setup() -> void:
	for state in [GAME_STATE_1813.bombay, GAME_STATE_1813.madras, GAME_STATE_1813.bengal]:
		assert_true(state.isCompanyControlled)
	assert_eq(GAME_STATE_1813.punjab.towerLevel, 2)
	assert_eq(GAME_STATE_1813.maratha.towerLevel, 2)
	assert_eq(GAME_STATE_1813.mysore.towerLevel, 2)
	assert_eq(GAME_STATE_1813.elephant.border_state_a, StateType.StateType.MYSORE)
	assert_eq(GAME_STATE_1813.elephant.facing_state, StateType.StateType.MADRAS)
	for sea in [GAME_STATE_1813.seaWest, GAME_STATE_1813.seaEast, GAME_STATE_1813.seaSouth]:
		assert_eq(sea.ships.size(), 1)
		assert_true(sea.ships[0].isCompanyShip())


func test_army_resource_survives_serialization() -> void:
	assert_eq(SINGLE_CRISIS.bombay.presidency, EnumTypes.Presidency.BOMBAY)
	assert_eq(SINGLE_CRISIS.bombay_presidency.army.regiments, 2)


func test_home_regions_have_fixed_presidencies_even_without_stored_assignment() -> void:
	var game_state := GameState.new()
	for assignment in [
		[StateType.StateType.BOMBAY, EnumTypes.Presidency.BOMBAY],
		[StateType.StateType.MADRAS, EnumTypes.Presidency.MADRAS],
		[StateType.StateType.BENGAL, EnumTypes.Presidency.BENGAL],
	]:
		var state := StateModel.new()
		state.location = assignment[0]
		assert_eq(game_state.get_presidency_type(state), assignment[1])
		state.presidency = EnumTypes.Presidency.BOMBAY
		assert_eq(game_state.get_presidency_type(state), assignment[1])


func test_acquired_region_uses_the_presidency_that_acquired_it() -> void:
	var game_state := GameState.new()
	var state := StateModel.new()
	state.location = StateType.StateType.MYSORE
	state.isCompanyControlled = true
	assert_eq(game_state.get_presidency_type(state), EnumTypes.Presidency.NONE)
	state.presidency = EnumTypes.Presidency.MADRAS
	assert_eq(game_state.get_presidency_type(state), EnumTypes.Presidency.MADRAS)
	assert_same(game_state.get_presidency(state), game_state.madras_presidency)


func test_army_and_alliance_survive_json_round_trip() -> void:
	var source := GameState.new()
	source.bombay = StateModel.new()
	source.bombay.isCompanyControlled = true
	source.bombay.presidency = EnumTypes.Presidency.BOMBAY
	source.bombay_presidency.army.regiments = 3
	var alliance := LocalAllianceModel.new()
	alliance.strength = 2
	source.bombay_presidency.army.local_alliances.append(alliance)
	var result := JSONConverter.parse(JSONConverter.stringify(source), GameState) as GameState
	assert_not_null(result)
	assert_eq(result.bombay_presidency.army.regiments, 3)
	assert_eq(result.bombay_presidency.army.local_alliances.size(), 1)
	assert_eq(result.bombay_presidency.army.local_alliances[0].strength, 2)
	assert_false(result.bombay_presidency.army.local_alliances[0].exhausted)


func test_game_states_have_separate_armies() -> void:
	var first := GameState.new()
	var second := GameState.new()
	first.bombay_presidency.army.regiments = 4
	assert_eq(second.bombay_presidency.army.regiments, 0)


func test_army_survives_save_game_resource_round_trip() -> void:
	var source := GameState.new()
	source.madras_presidency.army.officers = 2
	source.madras_presidency.army.exhausted_officers = 1
	var alliance := LocalAllianceModel.new()
	alliance.strength = 3
	source.madras_presidency.army.local_alliances.append(alliance)
	var path := "user://army_model_round_trip_test.tres"
	assert_eq(ResourceSaver.save(source, path), OK)
	var loaded := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as GameState
	assert_not_null(loaded)
	assert_eq(loaded.madras_presidency.army.officers, 2)
	assert_eq(loaded.madras_presidency.army.exhausted_officers, 1)
	assert_eq(loaded.madras_presidency.army.local_alliances[0].strength, 3)
	assert_false(loaded.madras_presidency.army.local_alliances[0].exhausted)
