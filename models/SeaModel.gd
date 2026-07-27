extends Resource
class_name SeaModel

@export var ships: Array[ShipModel]


func sink_ship(ship: ShipModel, sea_zone: String = "Unknown Sea") -> void:
	ships.erase(ship)
	ActionManager.add_action(
		ActionFactory.ship_action(ship.display_name(), sea_zone, "sunk")
	)
