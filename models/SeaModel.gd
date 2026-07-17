extends Resource
class_name SeaModel

@export var ships: Array[ShipModel]


func sink_ship(ship: ShipModel) -> void:
	ships.erase(ship)
