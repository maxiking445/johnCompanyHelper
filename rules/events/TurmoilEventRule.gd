extends Rule
class_name TurmoilEventRule

var cascadeRule := CascadeRule.new()

"""
TURMOIL EVENT

Close the northernmost open order in the region pictured on top of the draw
stack and return any writer on it to its player's supply. If every order in
that region is already closed, perform a Cascade instead.
"""

func execute(game_state: GameState) -> void:
	print("Executing TurmoilEventRule ...")
	var location: StateType.StateType = EventHelper.getTopDeckEventLocation()
	cascadeRule.execute_location(game_state, location)
