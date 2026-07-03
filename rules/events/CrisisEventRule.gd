extends Rule
class_name CrisisEventRule

var elephantMarchRule := ElephantMarchRule.new()

func execute(game_state: GameState) -> void:
	var attacker: StateType.StateType = game_state.elephant.get_backward_state()
	var defender: StateType.StateType = game_state.elephant.get_facing_state()
	
	var attackerState: StateModel = game_state.findStateByLocation(attacker)
	var defenderState: StateModel = game_state.findStateByLocation(defender)
	var eventCard: IndiaEvent = EventHelper.activeEvent
	if attackerState.isSovereign:
		var strengthModifier = eventCard.modifier
		pass
	elif attackerState.isDominated:
		var strengthModifier = eventCard.modifier
		pass
 	# After Crisis is resolved
	elephantMarchRule.execute(game_state)
