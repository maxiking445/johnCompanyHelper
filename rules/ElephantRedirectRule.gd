class_name ElephantRedirectRule
extends Rule

func execute(game_state: GameState) -> void:
	print("Executing ElephantRedirectRule ...")
	var location: StateType.StateType = game_state.elephant.current_state
	var state: StateModel = game_state.findStateByLocation(location)
	if state.hasRebelled:
		print("Perform ElephantsMarch")
	
