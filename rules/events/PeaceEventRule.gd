extends Rule
class_name PeaceEventRule

var elephantMarchRule := ElephantMarchRule.new()

"""
PEACE EVENT

If the Elephant stands on a border, open the orders connected through that
border and add one tower level to every touching region not controlled by the
Company. If it is wholly within a region, open all orders there and remove all
unrest from that region. Then perform the Elephant's March.
"""

func execute(game_state: GameState) -> void:
	print("Executing PeaceEventRule ...")
	print("Open any orders that are connected through the border the Elephant stands on. ")
	var elephant: ElephantModel = game_state.elephant

	if elephant.is_inside_state():
		game_state.openAllOrders(elephant.current_state)
		var state: StateModel = game_state.findStateByLocation(elephant.current_state)
		state.resetUnrest()

	elif elephant.is_on_border():
		var locations: Array[StateType.StateType] = elephant.getTouchingLocations()
		addTowerLevelToLocation(game_state, locations)
	
	elephantMarchRule.execute(game_state)

			
func addTowerLevelToLocation(game_state: GameState, locations: Array[StateType.StateType]):
	print("Then add one tower level to each region touching the Elephant that is not controlled by the Company. ")
	for location in locations:
		var state: StateModel = game_state.findStateByLocation(location)
		if state.isCompanyControlled:
			pass
		else:
			state.addTowerLevel()
