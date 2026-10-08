extends GutTest

const MAIN := preload("res://scenes/main.gd")


func after_each() -> void:
	EventHelper.draw_pile.clear()
	EventHelper.discard_pile.clear()
	EventHelper.activeEvent = null
	RollHelper.clearQueuedResults()
	ActionManager.clear()


func test_region_loss_marker_is_cleared_after_event() -> void:
	var game_state := GameState.new()
	var bombay := StateModel.new()
	bombay.location = StateType.StateType.BOMBAY
	bombay.isCompanyControlled = true
	bombay.presidency = EnumTypes.Presidency.BOMBAY
	game_state.bombay = bombay
	var event := IndiaEvent.new()
	event.eventName = "Company crisis"
	event.modifier = 1
	event.rule = AttackAgainstCompanyRule.new()
	var main = autofree(MAIN.new())

	var result: GameState = main.execute_event(
		game_state, event, StateType.StateType.BOMBAY
	)

	assert_false(result.bombay.hasRebelled)
	assert_false(result.bombay.isCompanyControlled)


func test_stale_marker_does_not_skip_orders_on_later_foreign_invasion() -> void:
	var game_state := GameState.new()
	var bombay := StateModel.new()
	bombay.location = StateType.StateType.BOMBAY
	bombay.isSovereign = true
	bombay.towerLevel = 1
	bombay.hasRebelled = true
	var order := OrderModel.new()
	order.id = &"BOM_1"
	order.state = StateType.StateType.BOMBAY
	bombay.orders = [order]
	game_state.bombay = bombay
	var event := IndiaEvent.new()
	event.eventName = "Foreign invasion"
	event.rule = ForeignInvasionEventRule.new()
	RollHelper.storm_dice_results = [StormDice.Face.WEST_2]
	RollHelper.d6_results = [3]
	var main = autofree(MAIN.new())

	var result: GameState = main.execute_event(
		game_state, event, StateType.StateType.BOMBAY
	)

	assert_true(result.bombay.orders[0].isClosed())
	assert_false(result.bombay.hasRebelled)


func test_marker_is_not_restored_from_saved_game() -> void:
	var game_state := GameState.new()
	game_state.bombay = StateModel.new()
	game_state.bombay.hasRebelled = true
	var path := "user://rebellion_marker_round_trip_test.tres"
	assert_eq(ResourceSaver.save(game_state, path), OK)

	var loaded := ResourceLoader.load(
		path, "", ResourceLoader.CACHE_MODE_IGNORE
	) as GameState

	assert_not_null(loaded)
	assert_false(loaded.bombay.hasRebelled)
