extends Rule
class_name LeaderEventRule

var looseRegionRule := LooseRegionRule.new()

func execute(game_state: GameState) -> void:
	print("Executing LeaderEventRule ...")
	looseRegionRule.reset_lost_regions_this_round()
	var location: StateType.StateType = EventHelper.getTopDeckEventLocation()
	var state: StateModel = game_state.findStateByLocation(location)

	if game_state.isStateSovereign(location):
		state.addTowerLevel()
	else:
		startRebellionIn(game_state, state)
		for stateWithUnrest in game_state.findAllStatesWithUnrest():
			if stateWithUnrest != state:
				startRebellionIn(game_state, stateWithUnrest)
				
func startRebellionIn(game_state: GameState, state: StateModel):
		var leaderEvent: IndiaEvent = EventHelper.activeEvent
		var strengthModifier: int = leaderEvent.modifier
		var attackStrength: int = strengthModifier + state.unrest_size

		var defenseStrength: int = state.troops - state.exhaustedTroops
		
		if attackStrength > defenseStrength:
			looseRegionRule.execute_for_state(game_state, state)
		else:
			state.exhaustTroops(attackStrength) 
			state.resetUnrest()	
			state.addThropyToken() 
			print("TODO: ElephantRedirect needs to be implemented")
