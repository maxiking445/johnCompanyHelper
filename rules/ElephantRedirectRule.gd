class_name ElephantRedirectRule
extends Rule

"""
ELEPHANT REDIRECT

If the Elephant is wholly inside a Company-controlled region when that region
is lost, redirect it by performing the required Elephant's March. A Company
attack elsewhere does not redirect an Elephant standing on a border.
"""

func execute(game_state: GameState) -> void:
	print("Executing ElephantRedirectRule ...")
	var location: StateType.StateType = game_state.elephant.current_state
	var state: StateModel = game_state.findStateByLocation(location)
	if state.hasRebelled:
		print("Perform ElephantsMarch")
	
