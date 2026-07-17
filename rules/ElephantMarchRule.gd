class_name ElephantMarchRule
extends Rule

"""
ELEPHANT'S MARCH

After resolving some events, the Elephant will move. First, check for Imperial
Ambitions. Otherwise, it will move to the region pictured on the top of the draw stack.

After checking Imperial Ambition, use the region pictured on top of the draw
stack. Put the Elephant inside a Company-controlled region. For a dominated
region, put it on the border facing the region that dominates it, indicating a
Rebellion. For a sovereign region, put it on the matching border indicated by
the event shape, indicating an Invasion.
"""

func execute(game_state: GameState) -> void:
	print("Executing ElephantMarchRule ...")
	print("Check for Imperial Ambition if not -> topdeck region")
	
	var location:StateType.StateType   = calculateElephantTargetRegion(game_state)
	
	
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

"""
After resolving a successful Invasion Crisis, the Elephant
will always be moved to the successful capital's region, regardless of which
tile is on top of the draw stack. 
"""
func calculateElephantTargetRegion(game_state: GameState)->StateType.StateType:
	var location:StateType.StateType 
	if game_state.hadASucessfullInvasionCrisis:
		location = game_state.consume_successful_invasion_capital()
	else:
		location = EventHelper.getTopDeckEventLocation()
	return location

func _place_for_sovereign_region( game_state: GameState, state: StateModel, elephant: ElephantModel) -> void:
	var target_location: StateType.StateType =  BoardMap.boardMap.findTheStateWhichTheElephantWillBorderWith(state.location, _get_elephant_shape())
	if target_location == StateType.StateType.NONE:
		push_error("No Elephant border found for this region and event shape.")
		return

	var target_state: StateModel = game_state.findStateByLocation(target_location)
	var caclulationState: StateModel =  findStateWhichIsNotDominated(game_state, state, elephant, target_state, 0 )
	if caclulationState == null:
		executeFullFormedEmpire(game_state, state, elephant)
		return

	elephant.placeOnBorderOf(caclulationState.location, state.location)
	elephant.is_on_border()



"""
If the Elephant faces a region that is already dominated by the region on
the top of the draw stack, use the first clockwise region from that border
where this is not true. 
"""
func findStateWhichIsNotDominated(	game_state: GameState, state: StateModel, elephant: ElephantModel, target_state: StateModel, count: int)-> StateModel:
	if count > 10:
		return null
	if target_state == null:
		return null
	if target_state.isDominatedByState(state):
		var newLocation: StateType.StateType = BoardMap.boardMap.findTheNextBorderOfThatState(state.location, target_state.location)
		if newLocation == StateType.StateType.NONE:
			return null
		target_state = game_state.findStateByLocation(newLocation)
		return findStateWhichIsNotDominated(game_state, state, elephant, target_state, count + 1)
	return target_state


"""
In the rare instance that all neighbors are
dominated, place the Elephant on
the border matching the shape on the
Elephant redirect arrow and position
it so that it is pointing at the empire's
capital. 
"""
func executeFullFormedEmpire(	game_state: GameState, state: StateModel, elephant: ElephantModel):
	var capital: StateModel= game_state.findEmpireCapital(state)
	var target_location: StateType.StateType =  BoardMap.boardMap.findTheStateWhichTheElephantWillBorderWith(state.location, _get_elephant_shape())
	if capital == null or target_location == StateType.StateType.NONE:
		return
	
	elephant.placeOnBorderOf(capital.location, target_location)
	elephant.is_on_border()


func _get_elephant_shape() -> EnumTypes.ElephantMarker:
	if EventHelper.activeEvent != null:
		return EventHelper.activeEvent.elephantShape
	if not EventHelper.draw_pile.is_empty():
		return EventHelper.draw_pile.front().elephantShape
	return EnumTypes.ElephantMarker.SQUARE


		
