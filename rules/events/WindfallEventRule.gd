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

	_apply_windfall_to_state(targetState)

	for connectedLocation in game_state.findConnectedLocations(targetLocation):
		var connectedState: StateModel = game_state.findStateByLocation(connectedLocation)
		if connectedState != null:
			_apply_windfall_to_state(connectedState)


func _apply_windfall_to_state(state: StateModel) -> void:
	state.treasury_size += state.writers
	print("Writers in ", StateType.name(state.location) ," gain ", state.writers, "$")
		
