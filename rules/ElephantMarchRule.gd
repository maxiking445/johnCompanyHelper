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
		print("If the region is sovereign, place the Elephant on the border matching the shape (circle, triangle, or square) printed on the tile to indicate a looming Invasion")
		
