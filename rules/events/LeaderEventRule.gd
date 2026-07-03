extends Rule
class_name LeaderEventRule

var attackAgainstCompanyRule := AttackAgainstCompanyRule.new()
var rebellionRule := RebellionRule.new()

func execute(game_state: GameState) -> void:
	print("Executing LeaderEventRule ...")
	var location: StateType.StateType = EventHelper.getTopDeckEventLocation()
	var state: StateModel = game_state.findStateByLocation(location)

	if state.isSovereign:
		state.addTowerLevel()
	elif state.isCompanyControlled:
		attackAgainstCompanyRule.execute_for_state(game_state, state)
	elif state.isDominated and state.isDominatedBy != null:
		rebellionRule.execute_detail(game_state, state, state.isDominatedBy)
	else:
		push_error("LeaderEventRule cannot resolve the pictured region state.")
