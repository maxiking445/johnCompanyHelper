extends Rule
class_name LeaderEventRule

var lostRegionsThisRound: int = 0

func execute(game_state: GameState) -> void:
	print("Executing LeaderEventRule ...")
	var location: StateType.StateType = EventHelper.getTopDeckEventLocation()
	var state: StateModel = game_state.findStateByLocation(location)

	if game_state.isStateSovereign(location):
		state.addTowerLevel()
	else:
		startRebellionIn(game_state, state)
		for stateWithUnrest in game_state.findAllStatesWithUnrest():
			if stateWithUnrest != state:
				startRebellionIn(game_state, stateWithUnrest)
				
	lostRegionsThisRound = 0			

func startRebellionIn(game_state: GameState, state: StateModel):
		var leaderEvent: IndiaEvent = EventHelper.activeEvent
		var strengthModifier: int = leaderEvent.modifier
		var attackStrength: int = strengthModifier + state.unrest_size

		var defenseStrength: int = state.troops - state.exhaustedTroops
		
		if attackStrength > defenseStrength:
			looseRegion(game_state, state)
		else:
			state.exhaustTroops(attackStrength) 
			state.resetUnrest()	
			state.addThropyToken()
			
func looseRegion(game_state: GameState, state: StateModel):
	if state.hasCommander:
		print("Tarnish the Commander's Name. Returns half (rounding up) of the trophies their family owns to the supply ")
		
	for officer_index in state.officers:
		if RollHelper.rollD6() == 6:
			print("Remove Officer (from left to right) Number: ", officer_index )
			state.removeOfficer()
			
	if state.hasGovenor:
		print("return it to the unused offices stack and return the officeholder's family member to that player's supply")
		
	state.resetUnrest()
	state.towerLevel = 1
	print("TODO: Close all order and/or cascade!")
	
	lostRegionsThisRound = lostRegionsThisRound + 1
	game_state.lowerCompanyStanding(lostRegionsThisRound)
	
	
