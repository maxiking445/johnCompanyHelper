extends Rule
class_name TurmoilEventRule

func execute(game_state: GameState) -> void:
	print("Executing TurmoilEventRule ...")
	var location: StateType.StateType = EventHelper.getTopDeckEventLocation()
	checkLocation(game_state, location)

func checkLocation(game_state: GameState, location:  StateType.StateType):
	if (game_state.areAllOrderClosed(location)):
		cascade(game_state, location)
	else:
		game_state.closeNorthestOrder(location)
		
func cascade(game_state: GameState, location:  StateType.StateType):
	print("Cascaded Location: ", StateType.name(location))
	var connectedLocations: Array[StateType.StateType] =  game_state.findConnectedLocations(location)
	for connectedLocation in connectedLocations:
		checkLocation(game_state, connectedLocation)
