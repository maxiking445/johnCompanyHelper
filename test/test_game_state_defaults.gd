extends GutTest

const GAME_STATE_1710 := preload("res://resources/gameState/GameState1710.tres")
const GAME_STATE_1758 := preload("res://resources/gameState/GameState1758.tres")
const GAME_STATE_1813 := preload("res://resources/gameState/GameState1813.tres")


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
