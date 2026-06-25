extends Rule
class_name TurmoilEventRule

var cascadeRule := CascadeRule.new()

func execute(game_state: GameState) -> void:
	print("Executing TurmoilEventRule ...")
	var location: StateType.StateType = EventHelper.getTopDeckEventLocation()
	cascadeRule.execute_location(game_state, location)
