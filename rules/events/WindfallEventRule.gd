extends Rule
class_name WindfallEventRule

func execute(game_state: GameState) -> void:
	print("Executing WinfdallEventRule ...")
	var targetLocation: StateType.StateType  = EventHelper.getTopDeckEventLocation()
	print("Target of Event is ", StateType.name(targetLocation))
	var targetState: StateModel = game_state.findStateByLocation(targetLocation)

	if targetState == null:
		printerr("Location ", StateType.name(targetLocation) ," in WindfallEventRule is not defined! Please fix!")
		return
		
	for writer in targetState.writers:
		print("Writer in ", StateType.name(targetLocation) ," gains 1$")
		
