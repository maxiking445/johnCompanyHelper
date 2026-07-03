extends Rule
class_name LeaderEventRule

var attackAgainstCompanyRule := AttackAgainstCompanyRule.new()

func execute(game_state: GameState) -> void:
	print("Executing LeaderEventRule ...")
	var location: StateType.StateType = EventHelper.getTopDeckEventLocation()
	var state: StateModel = game_state.findStateByLocation(location)

	if game_state.isStateSovereign(location):
		state.addTowerLevel()
	else:
		attackAgainstCompanyRule.execute_for_state(game_state, state)
