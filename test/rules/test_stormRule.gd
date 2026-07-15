extends GutTest

const STORM_RULE := preload("res://rules/StormRule.gd")
const GAME_STATE := preload("res://resources/gameState/GameState1710.tres")

var _rule: StormRule
var _game_state: GameState


func before_each() -> void:
	_rule = STORM_RULE.new()
	_game_state = GAME_STATE.duplicate(true)
	RollHelper.clearQueuedResults()
	_clear_seas()


func after_each() -> void:
	RollHelper.clearQueuedResults()


func test_execute_sets_events_to_draw_without_checking_sea_zones_on_four_result() -> void:
	var player_ship := _create_ship(ShipTypes.ShipType.PLAYER, "Player")
	_game_state.seaEast.ships = [player_ship]
	RollHelper.storm_dice_results = [StormDice.Face.FOUR_A]
	RollHelper.d6_results = [6]

	_rule.execute(_game_state)

	assert_eq(_game_state.eventsToDraw, 4)
	assert_true(_game_state.seaEast.ships.has(player_ship))
	assert_false(player_ship.isDamaged())
	assert_eq(RollHelper.d6_results.size(), 1)


func test_execute_damages_player_ship_in_targeted_zone_on_roll_four() -> void:
	var player_ship := _create_ship(ShipTypes.ShipType.PLAYER, "Player")
	_game_state.seaEast.ships = [player_ship]
	RollHelper.storm_dice_results = [StormDice.Face.EAST_2]
	RollHelper.d6_results = [4]

	_rule.execute(_game_state)

	assert_eq(_game_state.eventsToDraw, 2)
	assert_true(_game_state.seaEast.ships.has(player_ship))
	assert_true(player_ship.isDamaged())


func test_execute_sinks_player_ship_in_targeted_zone_on_roll_six() -> void:
	var player_ship := _create_ship(ShipTypes.ShipType.PLAYER, "Player")
	_game_state.seaWest.ships = [player_ship]
	RollHelper.storm_dice_results = [StormDice.Face.WEST_2]
	RollHelper.d6_results = [6]

	_rule.execute(_game_state)

	assert_eq(_game_state.eventsToDraw, 2)
	assert_false(_game_state.seaWest.ships.has(player_ship))


func test_execute_ignores_company_and_extra_ships() -> void:
	var company_ship := _create_ship(ShipTypes.ShipType.COMPANY, "Company")
	var extra_ship := _create_ship(ShipTypes.ShipType.EXTRA, "Extra")
	_game_state.seaSouth.ships = [company_ship, extra_ship]
	RollHelper.storm_dice_results = [StormDice.Face.SOUTH_3]
	RollHelper.d6_results = [6, 6]

	_rule.execute(_game_state)

	assert_eq(_game_state.eventsToDraw, 3)
	assert_true(_game_state.seaSouth.ships.has(company_ship))
	assert_true(_game_state.seaSouth.ships.has(extra_ship))
	assert_eq(RollHelper.d6_results.size(), 2)


func test_execute_checks_all_zones_when_storm_hits_all() -> void:
	var south_ship := _create_ship(ShipTypes.ShipType.PLAYER, "South")
	var west_ship := _create_ship(ShipTypes.ShipType.PLAYER, "West")
	var east_ship := _create_ship(ShipTypes.ShipType.PLAYER, "East")
	_game_state.seaSouth.ships = [south_ship]
	_game_state.seaWest.ships = [west_ship]
	_game_state.seaEast.ships = [east_ship]
	RollHelper.storm_dice_results = [StormDice.Face.STORMS_ALL]
	RollHelper.d6_results = [1, 4, 6]

	_rule.execute(_game_state)

	assert_eq(_game_state.eventsToDraw, 1)
	assert_true(_game_state.seaSouth.ships.has(south_ship))
	assert_false(south_ship.isDamaged())
	assert_true(_game_state.seaWest.ships.has(west_ship))
	assert_true(west_ship.isDamaged())
	assert_false(_game_state.seaEast.ships.has(east_ship))


func _clear_seas() -> void:
	_game_state.seaSouth.ships.clear()
	_game_state.seaWest.ships.clear()
	_game_state.seaEast.ships.clear()


func _create_ship(ship_type: ShipTypes.ShipType, owner: String) -> ShipModel:
	var ship := ShipModel.new()
	ship.shipType = ship_type
	ship.shipOwner = owner
	ship.isFlipped = false
	return ship
