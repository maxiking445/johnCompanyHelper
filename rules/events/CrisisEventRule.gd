extends Rule
class_name CrisisEventRule

var elephantMarchRule := ElephantMarchRule.new()
var invasionRule:= InvasionRule.new()
var rebellionRule:= RebellionRule.new()
var attackAgainstCompanyRule := AttackAgainstCompanyRule.new()

"""
Like Peace, the location of the Crisis is determined by the placement of
the Elephant piece, not by the top tile of the draw stack. The Elephant's
tail (where it is walking.from) indicates the attacker. The Elephant's head
(where it is walking to) indicates the defender. After resolving a Crisis,
perform the Elephant's March. 

	* If the attacker is a sovereign region, resolve an Invasion.
	* If the attacker is a dominated region, resolve a Rebellion.
	* Both Invasions and Rebellions against Company-controlled regions are
	resolved the same way
	
"""
func execute(game_state: GameState) -> void:
	if game_state == null or game_state.elephant == null:
		push_error("CrisisEventRule needs a game state with an Elephant.")
		return

	if game_state.elephant.is_inside_state():
		var company_state := game_state.findStateByLocation(
			game_state.elephant.current_state
		)
		if company_state == null or not company_state.isCompanyControlled:
			push_error("A Crisis inside a region requires Company control.")
			return
		attackAgainstCompanyRule.execute_for_state(game_state, company_state)
		elephantMarchRule.execute(game_state)
		return

	var attacker: StateType.StateType = game_state.elephant.get_backward_state()
	var defender: StateType.StateType = game_state.elephant.get_facing_state()
	
	var attackerState: StateModel = game_state.findStateByLocation(attacker)
	var defenderState: StateModel = game_state.findStateByLocation(defender)
	if defenderState.isCompanyControlled:
		if attackerState.isSovereign:
			var invasion_strength := invasionRule.calculate_attack_strength(
				game_state, attackerState
			)
			attackAgainstCompanyRule.execute_for_state(
				game_state, defenderState, invasion_strength, attackerState
			)
		elif attackerState.isDominated:
			attackAgainstCompanyRule.execute_for_state(
				game_state,
				defenderState,
				rebellionRule.calculate_attack_strength(attackerState)
			)
		else:
			push_error("The Crisis attacker must be sovereign or dominated.")
	elif attackerState.isSovereign:
		invasionRule.execute_detail(game_state, attackerState, defenderState)
	elif attackerState.isDominated:
		rebellionRule.execute_detail(game_state, attackerState, defenderState)
		
 	# After Crisis is resolved
	elephantMarchRule.execute(game_state)
