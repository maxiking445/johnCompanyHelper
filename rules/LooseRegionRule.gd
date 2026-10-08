extends Rule
class_name LooseRegionRule

"""
REGION LOSS

When the Company loses a region, tarnish the associated Commander's name,
resolve the officer rout, eliminate its Governor, and restore local authority.
Remove unrest, restore one tower level, close all orders (or Cascade if they
were already closed), and lower Company Standing. Each additional region lost
in the same resolution increases the Standing penalty by one.
"""

var lostRegionsThisRound: int = 0
var cascadeRule := CascadeRule.new()

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

	performTarnishCommandersName(game_state, state)
	
	performOfficerRoute(game_state, state)

	performGovernerElimination(game_state, state)

	performRestoreLocalAuthority(game_state, state)
		
	performHumiliation(game_state)	
	
	state.stateHasRebelled()


func performTarnishCommandersName(game_state: GameState, state: StateModel):
	var presidency := game_state.get_presidency(state)
	if presidency != null and presidency.has_commander:
		print("Tarnish the Commander's Name. Returns half (rounding up) of the trophies their family owns to the supply ")
		
func performOfficerRoute(game_state: GameState, state: StateModel):
	var presidency := game_state.get_presidency(state)
	if presidency == null or presidency.army == null:
		return
	var army := presidency.army
	for officer_index in army.officers:
		if RollHelper.rollD6() == 6:
			print("Remove Officer (from left to right) Number: ", officer_index )
			army.remove_officer(game_state.get_presidency_name(state))

func performGovernerElimination(game_state: GameState, state: StateModel):
	if state.hasGovernor:
		print("return it to the unused offices stack and return the officeholder's family member to that player's supply")

func performRestoreLocalAuthority(game_state: GameState, state: StateModel):
	state.restore_local_authority()
	
	if game_state.areAllOrderClosed(state.location):
		cascadeRule.execute_location(game_state, state.location)
	else:
		game_state.closeAllOrders(state.location)	
		
func performHumiliation(game_state: GameState):
	lostRegionsThisRound = lostRegionsThisRound + 1
	ActionManager.add_action(
		ActionFactory.lower_company_standing_action(lostRegionsThisRound)
	)
