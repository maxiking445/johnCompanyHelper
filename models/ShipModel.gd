extends Resource
class_name ShipModel

@export var shipType: ShipTypes.ShipType
@export var shipOwner: String
@export var isFlipped: bool

	
func isCompanyShip() -> bool:
	return shipType == ShipTypes.ShipType.COMPANY

func isExtraShip() -> bool:
	return shipType == ShipTypes.ShipType.EXTRA

func isDamaged() -> bool:
	return isFlipped

func damageShip()->void:
	self.isFlipped = true
