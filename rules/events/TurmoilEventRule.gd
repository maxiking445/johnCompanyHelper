extends Rule
class_name TurmoilEventRule

var allreadyCascadedLocations: Array[StateType.StateType]
# TODO Connect all TradeOrders together so we can define them better and connect them and their roots
func execute(game_state: GameState) -> void:
	print("Executing TurmoilEventRule ...")
	var location: StateType.StateType = EventHelper.getTopDeckEventLocation()
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
				for connectedOrder in order.connectedOrders:
					if connectedOrder.isOpen():
						connectedOrder.close()
					else:
						if (game_state.areAllOrderClosed(location)):
							checkLocation(game_state, order.state)
						else:
							game_state.closeNorthestOrder(location)
				pass
			cascade(game_state, location)
	else:
		game_state.closeNorthestOrder(location)
		
func cascade(game_state: GameState, location:  StateType.StateType):
	print("Cascaded Location: ", StateType.name(location))
	var connectedLocations: Array[StateType.StateType] =  game_state.findConnectedLocations(location)
	for connectedLocation in connectedLocations:
		
		checkLocation(game_state, connectedLocation)
