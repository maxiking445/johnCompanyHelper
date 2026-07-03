extends Rule
class_name LeaderEventRule

var attackAgainstCompanyRule := AttackAgainstCompanyRule.new()
var rebellionRule := RebellionRule.new()
var elephantRedirectRule := ElephantRedirectRule.new()

"""
LEADER EVENT

Look at the region pictured on top of the draw stack. If it is sovereign, add
one tower level. Otherwise treat the event as a Rebellion in that region, with
the explosion number as its strength modifier. A Company-controlled target is
resolved as an Attack against the Company; a dominated target uses the normal
Rebellion procedure.
"""

func execute(game_state: GameState) -> void:
	print("Executing LeaderEventRule ...")
	var location: StateType.StateType = EventHelper.getTopDeckEventLocation()
	var state: StateModel = game_state.findStateByLocation(location)

	if state.isSovereign:
		state.addTowerLevel()
	elif state.isCompanyControlled:
		var rebellion_succeeded := attackAgainstCompanyRule.execute_for_state(
			game_state, state
		)
		if rebellion_succeeded:
			elephantRedirectRule.execute(game_state)
	elif state.isDominated and state.isDominatedBy != null:
		rebellionRule.execute_detail(game_state, state, state.isDominatedBy)
	else:
		push_error("LeaderEventRule cannot resolve the pictured region state.")
