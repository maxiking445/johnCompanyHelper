extends GutTest

const CRISIS_EVENT_RULE := preload("res://rules/events/CrisisEventRule.gd")

var _rule: CrisisEventRule
var _game_state: GameState


func before_each() -> void:
	_rule = CRISIS_EVENT_RULE.new()
	_game_state = GameState.new()
	_game_state.elephant = ElephantModel.new()
	EventHelper.draw_pile = []
	EventHelper.activeEvent = null


func after_each() -> void:
	EventHelper.draw_pile.clear()
	EventHelper.activeEvent = null


func test_crisis_inside_company_region_uses_company_attack() -> void:
	var company_state := _create_state(StateType.StateType.BOMBAY)
	company_state.isCompanyControlled = true
	company_state.unrest_size = 2
	company_state.presidency = 1
	_game_state.bombay_presidency.army.regiments = 3
	_game_state.states = [company_state]
	_game_state.elephant.placeInCenterOf(company_state.location)
	_set_event(company_state.location, 1)

	_rule.execute(_game_state)

	assert_eq(_game_state.bombay_presidency.army.exhausted_regiments, 3)
	assert_eq(company_state.unrest_size, 0)


func test_invasion_against_company_uses_empire_strength_and_unrest() -> void:
	var attacker := _create_state(StateType.StateType.PUNJAB)
	attacker.isSovereign = true
	attacker.towerLevel = 2
	var company_state := _create_state(StateType.StateType.DELHI)
	company_state.isCompanyControlled = true
	company_state.unrest_size = 1
	company_state.presidency = 3
	_game_state.bengal_presidency.army.regiments = 3
	_game_state.states = [attacker, company_state]
	_game_state.elephant.placeOnBorderOf(company_state.location, attacker.location)
	_set_event(company_state.location, 1)

	_rule.execute(_game_state)

	assert_true(company_state.hasRebelled)
	assert_false(company_state.isCompanyControlled)
	assert_true(attacker.isPartOfEmpire())
	assert_eq(company_state.partOfEmpire, attacker.partOfEmpire)


func test_failed_invasion_against_company_removes_attacker_tower() -> void:
	var attacker := _create_state(StateType.StateType.PUNJAB)
	attacker.isSovereign = true
	attacker.towerLevel = 2
	var company_state := _create_state(StateType.StateType.DELHI)
	company_state.isCompanyControlled = true
	company_state.presidency = 3
	_game_state.bengal_presidency.army.regiments = 5
	_game_state.states = [attacker, company_state]
	_game_state.elephant.placeOnBorderOf(company_state.location, attacker.location)
	_set_event(company_state.location, 0)

	_rule.execute(_game_state)

	assert_eq(attacker.towerLevel, 1)
	assert_true(company_state.isCompanyControlled)


func _set_event(next_location: StateType.StateType, modifier: int) -> void:
	var event := IndiaEvent.new()
	event.eventLocation = next_location
	event.modifier = modifier
	event.elephantShape = EnumTypes.ElephantMarker.SQUARE
	EventHelper.draw_pile = [event]
	EventHelper.activeEvent = event


func _create_state(location: StateType.StateType) -> StateModel:
	var state := StateModel.new()
	state.location = location
	state.orders = []
	return state
