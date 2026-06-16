extends Node
class_name ShipModel

var shipType: ShipTypes.ShipType
var shipOwner: String
var isFlipped: bool

func _init(ship_type: ShipTypes.ShipType, ship_owner: String, isFlipped: bool):
	self.shipType = ship_type
	self.shipOwner = ship_owner
	self.isFlipped = isFlipped
	
	
func isCompanyShip() -> bool:
	return shipType == ShipTypes.ShipType.COMPANY

func isExtraShip() -> bool:
	return shipType == ShipTypes.ShipType.EXTRA

func isDamaged() -> bool:
	return isFlipped

func damageShip()->void:
	self.isFlipped = true
