extends Rule
class_name CascadeRule

"""
CASCADE

If the affected region still has an open order, close its northernmost open
order. If every order is already closed, follow each connected order: close an
open connected order, or continue the Cascade from its region when it is also
closed. A region is resolved at most once during the same Cascade.
"""

var allreadyCascadedLocations: Array[StateType.StateType]

func execute(game_state: GameState) -> void:
	var location: StateType.StateType = EventHelper.getTopDeckEventLocation()
	checkLocation(game_state, location)
	allreadyCascadedLocations.clear()

func execute_location(game_state: GameState, location: StateType.StateType) -> void:
	checkLocation(game_state, location)
	allreadyCascadedLocations.clear()
	

func checkLocation(game_state: GameState, location:  StateType.StateType):
	if (game_state.areAllOrderClosed(location)):
		if allreadyCascadedLocations.has(location):
			print("Location already Cascaded Skip!: ", StateType.name(location))
		else:
			allreadyCascadedLocations.append(location)
			var state: StateModel = game_state.findStateByLocation(location)
			for order in state.orders:
				for connected_order_id in BoardMap.boardMap.findConnectedOrderIds(order.id):
					var connectedOrder := game_state.findOrderById(connected_order_id)
					if connectedOrder == null:
						push_error("Connected order not found: %s" % connected_order_id)
						continue
					if connectedOrder.isOpen():
						_add_cascade_action(location, connectedOrder.state)
						connectedOrder.close()
					elif not allreadyCascadedLocations.has(connectedOrder.state):
						_add_cascade_action(location, connectedOrder.state)
						checkLocation(game_state, connectedOrder.state)
	else:
		game_state.closeNorthestOrder(location)


func _add_cascade_action(
	origin: StateType.StateType,
	destination: StateType.StateType
) -> void:
	ActionManager.add_action(
		ActionFactory.cascade_action(
			StateType.name(origin), StateType.name(destination)
		)
	)
