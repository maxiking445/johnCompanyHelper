extends Rule
class_name ForeignInvasionEventRule

var attack_against_company_rule := AttackAgainstCompanyRule.new()
var cascade_rule := CascadeRule.new()
var invasion_rule := InvasionRule.new()
var elephant_redirect_rule := ElephantRedirectRule.new()

"""
FOREIGN INVASION EVENT

Roll the storm die and resolve an Invasion Crisis or an Attack against the
Company in each region linked to a storm: Bombay for West Indian, Madras for
South Indian, and Bengal for East Indian. Resolve all three when all storms are
rolled. If no storm is rolled, use the region on top of the draw stack.

For each affected region, roll a die and use the result as the Invasion's base
strength. A successful invasion closes its orders, removes its empire flag or
Company control, and sets its new strength to half the invasion strength,
rounded down.

Elephant Redirect: If the Elephant was fully within a Company-controlled
region that was invaded, perform an Elephant's March using the circle shape.
Otherwise this event does not move the Elephant.
"""

func execute(game_state: GameState) -> void:
	print("Executing ForeignInvasionEventRule ...")
	if game_state == null:
		push_error("ForeignInvasionEventRule needs a game state.")
		return

	var affected_states := determine_affected_states_by_storm(game_state)
	if affected_states.is_empty():
		var fallback_state := game_state.findStateByLocation(EventHelper.getTopDeckEventLocation())
		affected_states.append(fallback_state)

	for state in affected_states:
		_resolve_invasion(game_state, state, RollHelper.rollD6())


func determine_affected_states_by_storm(
	game_state: GameState
) -> Array[StateModel]:
	var storm_result := RollHelper.rollStormDice()
	var locations: Array[StateType.StateType] = []
	match storm_result:
		StormDice.Face.SOUTH_3:
			locations.append(StateType.StateType.MADRAS)
		StormDice.Face.WEST_2:
			locations.append(StateType.StateType.BOMBAY)
		StormDice.Face.EAST_2:
			locations.append(StateType.StateType.BENGAL)
		StormDice.Face.STORMS_ALL:
			locations.assign([
				StateType.StateType.BENGAL,
				StateType.StateType.BOMBAY,
				StateType.StateType.MADRAS,
			])

	var affected_states: Array[StateModel] = []
	for location in locations:
		var state := game_state.findStateByLocation(location)
		if state != null:
			affected_states.append(state)
	return affected_states


# Keep the original method name for existing callers.
func determineAffectesStatesByStorm(game_state: GameState) -> Array[StateModel]:
	return determine_affected_states_by_storm(game_state)


func _resolve_invasion(
	game_state: GameState,
	state: StateModel,
	invasion_strength: int
) -> void:
	if state.isCompanyControlled:
		var succeeded := attack_against_company_rule.execute_for_state(
			game_state, state, invasion_strength, null, "Foreign invaders"
		)
		if succeeded:
			apply_success(game_state, state, invasion_strength)
			elephant_redirect_rule.execute_with_circle_shape(game_state)
		return

	if invasion_rule.is_invasion_successful(
		game_state, state, invasion_strength
	):
		_add_foreign_invasion_actions(
			game_state, state, invasion_strength, true
		)
		apply_success(game_state, state, invasion_strength)
	else:
		_add_foreign_invasion_actions(
			game_state, state, invasion_strength, false
		)


func _add_foreign_invasion_actions(
	game_state: GameState,
	state: StateModel,
	invasion_strength: int,
	succeeded: bool
) -> void:
	var attacker_name := "Foreign invaders"
	var defender_name := StateType.name(state.location)
	var defense_strength := invasion_rule.calculate_defense_strength(
		game_state, state
	)
	ActionManager.add_action(
		ActionFactory.battle_started_action(
			attacker_name, defender_name, invasion_strength, defense_strength
		)
	)
	ActionManager.add_action(
		ActionFactory.invasion_result_action(
			attacker_name, defender_name, succeeded
		)
	)
	ActionManager.add_action(
		ActionFactory.battle_result_action(
			attacker_name,
			defender_name,
			attacker_name if succeeded else defender_name
		)
	)


func apply_success(
	game_state: GameState,
	state: StateModel,
	invasion_strength: int
) -> void:
	var defeated_empire := state.partOfEmpire
	if state.isEmpireCapital and defeated_empire != EnumTypes.Empires.NONE:
		game_state.dissolve_empire(defeated_empire)

	state.resolve_foreign_invasion(invasion_strength)

	# Region Loss already handles orders for Company-controlled targets.
	if not state.hasRebelled:
		if game_state.areAllOrderClosed(state.location):
			cascade_rule.execute_location(game_state, state.location)
		else:
			game_state.closeAllOrders(state.location)
