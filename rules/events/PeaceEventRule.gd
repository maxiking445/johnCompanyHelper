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
		_open_orders_across_border(game_state, locations)
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


# Only orders joined across the Elephant's current border are opened.
# Other orders in the two touching regions must remain unchanged.
func _open_orders_across_border(game_state: GameState, locations: Array[StateType.StateType]) -> void:
	if locations.size() != 2:
		return
	var first_state := game_state.findStateByLocation(locations[0])
	var second_state := game_state.findStateByLocation(locations[1])
	if first_state == null or second_state == null:
		return

	for first_order in first_state.orders:
		for connected_id in BoardMap.boardMap.findConnectedOrderIds(first_order.id):
			for second_order in second_state.orders:
				if second_order.id == connected_id:
					first_order.open()
					second_order.open()
