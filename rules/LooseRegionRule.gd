extends Rule
class_name LooseRegionRule

var lostRegionsThisRound: int = 0

func execute(game_state: GameState) -> void:
	var location: StateType.StateType = EventHelper.getTopDeckEventLocation()
	execute_for_location(game_state, location)

func reset_lost_regions_this_round() -> void:
	lostRegionsThisRound = 0


func execute_for_location(game_state: GameState, location: StateType.StateType) -> void:
	print("Executing LooseRegionRule ...")
	var state: StateModel = game_state.findStateByLocation(location)
	execute_for_state(game_state, state)


func execute_for_state(game_state: GameState, state: StateModel) -> void:
	if state == null:
		push_error("LooseRegionRule needs a valid state.")
		return

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
