extends Rule
class_name WindfallEventRule

var windfallLogMessages: Array[String] = []


func execute(game_state: GameState) -> void:
	windfallLogMessages.clear()
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
	for writer_index in state.writers:
		var message := "Writer in %s gains 1$" % StateType.name(state.location)
		windfallLogMessages.append(message)
		print(message)
		
