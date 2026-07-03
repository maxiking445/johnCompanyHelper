extends Rule
class_name CrisisEventRule

var elephantMarchRule := ElephantMarchRule.new()
var invasionRule:= InvasionRule.new()
var rebellionRule:= RebellionRule.new()

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
	var attacker: StateType.StateType = game_state.elephant.get_backward_state()
	var defender: StateType.StateType = game_state.elephant.get_facing_state()
	
	var attackerState: StateModel = game_state.findStateByLocation(attacker)
	var defenderState: StateModel = game_state.findStateByLocation(defender)
	var eventCard: IndiaEvent = EventHelper.activeEvent
	if attackerState.isSovereign:
		invasionRule.execute_detail(game_state, attackerState, defenderState)
	elif attackerState.isDominated:
		rebellionRule.execute_detail(game_state, attackerState, defenderState)
		
 	# After Crisis is resolved
	elephantMarchRule.execute(game_state)
