class_name ElephantMarchRule
extends Rule

"""
ELEPHANT'S MARCH

After checking Imperial Ambition, use the region pictured on top of the draw
stack. Put the Elephant inside a Company-controlled region. For a dominated
region, put it on the border facing the region that dominates it, indicating a
Rebellion. For a sovereign region, put it on the matching border indicated by
the event shape, indicating an Invasion.
"""

func execute(game_state: GameState) -> void:
	print("Executing ElephantMarchRule ...")
	print("Check for Imperial Ambition if not -> topdeck region")
	
	var location:StateType.StateType   = EventHelper.getTopDeckEventLocation()
	var state: StateModel =  	game_state.findStateByLocation(location)
	var elephant: ElephantModel = game_state.elephant
	if state.isCompanyControlled:
		print(" If the region is Company-controlled, put the Elephant in the center of the region.")
		elephant.placeInCenterOf(location)
	elif state.isDominated:
		print(" If the region is currently dominated by another region, place the Elephant on the border facing its current sovereign to indicate a looming Rebellion.")
		var dominatingState: StateModel = state.isDominatedBy
		elephant.placeOnBorderOf(dominatingState.location, location)
	elif state.isSovereign:
		_place_for_sovereign_region(game_state, state, elephant)


func _place_for_sovereign_region(
	game_state: GameState,
	state: StateModel,
	elephant: ElephantModel
) -> void:
	if state.is_connected_to.is_empty():
		push_error("A sovereign region needs at least one connected border.")
		return

	var start_index := 0
	if not EventHelper.draw_pile.is_empty():
		start_index = posmod(
			EventHelper.draw_pile.front().elephantBorderIndex,
			state.is_connected_to.size()
		)

	# Connections are stored clockwise, starting at the border represented by
	# elephantBorderIndex. Skip regions already dominated by this sovereign.
	for offset in state.is_connected_to.size():
		var connection_index := (start_index + offset) % state.is_connected_to.size()
		var target_location := state.is_connected_to[connection_index]
		var target_state := game_state.findStateByLocation(target_location)
		if target_state == null or not _is_dominated_by(target_state, state):
			elephant.placeOnBorderOf(target_location, state.location)
			return

	# Fully-formed empire: all neighboring regions are already dominated. Use
	# the redirect arrow and point back at the empire's sovereign capital.
	var capital: StateModel= game_state.findEmpireCapital(state)
	elephant.placeOnBorderOf(capital.location, state.location)


func _is_dominated_by(target: StateModel, sovereign: StateModel) -> bool:
	if not target.isDominated:
		return false
	if target.isDominatedBy == sovereign:
		return true
	return (
		sovereign.isPartOfEmpire()
		and target.partOfEmpire == sovereign.partOfEmpire
	)



		
