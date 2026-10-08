extends GutTest

const FOREIGN_INVASION_RULE := preload(
	"res://rules/events/ForeignInvasionEventRule.gd"
)

var _rule: ForeignInvasionEventRule
var _game_state: GameState


func before_each() -> void:
	_rule = FOREIGN_INVASION_RULE.new()
	_game_state = GameState.new()
	RollHelper.clearQueuedResults()
	EventHelper.draw_pile = []


func after_each() -> void:
	RollHelper.clearQueuedResults()
	EventHelper.draw_pile.clear()


func test_west_storm_resolves_foreign_invasion_in_bombay() -> void:
	var bombay := _create_state(StateType.StateType.BOMBAY, 2)
	var madras := _create_state(StateType.StateType.MADRAS, 2)
	_game_state.states = [bombay, madras]
	_queue_rolls(StormDice.Face.WEST_2, [5])

	_rule.execute(_game_state)

	assert_eq(bombay.towerLevel, 2)
	assert_true(bombay.orders[0].isClosed())
	assert_true(madras.orders[0].isOpen())


func test_no_storm_uses_top_draw_stack_region() -> void:
	var punjab := _create_state(StateType.StateType.PUNJAB, 1)
	_game_state.states = [punjab]
	_set_top_deck_location(punjab.location)
	_queue_rolls(StormDice.Face.FOUR_A, [4])

	_rule.execute(_game_state)

	assert_eq(punjab.towerLevel, 2)
	assert_true(punjab.orders[0].isClosed())


func test_all_storms_resolve_bengal_bombay_and_madras() -> void:
	var bengal := _create_state(StateType.StateType.BENGAL, 1)
	var bombay := _create_state(StateType.StateType.BOMBAY, 1)
	var madras := _create_state(StateType.StateType.MADRAS, 1)
	_game_state.states = [bengal, bombay, madras]
	_queue_rolls(StormDice.Face.STORMS_ALL, [2, 2, 2])

	_rule.execute(_game_state)

	assert_true(bengal.orders[0].isClosed())
	assert_true(bombay.orders[0].isClosed())
	assert_true(madras.orders[0].isClosed())


func test_tied_foreign_invasion_fails() -> void:
	var bengal := _create_state(StateType.StateType.BENGAL, 3)
	_game_state.states = [bengal]
	_queue_rolls(StormDice.Face.EAST_2, [3])

	_rule.execute(_game_state)

	assert_eq(bengal.towerLevel, 3)
	assert_true(bengal.orders[0].isOpen())


func test_successful_company_invasion_uses_unrest_and_army_defense() -> void:
	var madras := _create_state(StateType.StateType.MADRAS, 0)
	madras.isCompanyControlled = true
	madras.unrest_size = 1
	madras.presidency = EnumTypes.Presidency.MADRAS
	_game_state.madras_presidency.army.regiments = 3
	_game_state.states = [madras]
	_queue_rolls(StormDice.Face.SOUTH_3, [3])

	_rule.execute(_game_state)

	assert_true(madras.hasRebelled)
	assert_false(madras.isCompanyControlled)
	assert_eq(_game_state.madras_presidency.army.exhausted_regiments, 3)
	assert_eq(madras.towerLevel, 1)


func test_failed_company_invasion_awards_trophy_and_removes_unrest() -> void:
	var madras := _create_state(StateType.StateType.MADRAS, 0)
	madras.isCompanyControlled = true
	madras.unrest_size = 1
	madras.presidency = EnumTypes.Presidency.MADRAS
	_game_state.madras_presidency.army.regiments = 4
	_game_state.states = [madras]
	_queue_rolls(StormDice.Face.SOUTH_3, [3])

	_rule.execute(_game_state)

	assert_true(madras.isCompanyControlled)
	assert_eq(madras.unrest_size, 0)
	assert_eq(_game_state.madras_presidency.army.exhausted_regiments, 4)


func _queue_rolls(storm: StormDice.Face, d6_results: Array[int]) -> void:
	RollHelper.storm_dice_results = [storm]
	RollHelper.d6_results = d6_results


func _set_top_deck_location(location: StateType.StateType) -> void:
	var event := IndiaEvent.new()
	event.eventLocation = location
	EventHelper.draw_pile = [event]


func _create_state(
	location: StateType.StateType,
	tower_level: int
) -> StateModel:
	var state := StateModel.new()
	state.location = location
	state.towerLevel = tower_level
	var order := OrderModel.new()
	order.state = location
	order.open()
	state.orders = [order]
	return state
