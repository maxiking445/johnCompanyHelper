extends Resource
class_name ShipModel

@export var shipType: ShipTypes.ShipType
@export var isFlipped: bool


func display_name() -> String:
	match shipType:
		ShipTypes.ShipType.PLAYER:
			return "Player ship"
		ShipTypes.ShipType.COMPANY:
			return "Company ship"
		ShipTypes.ShipType.EXTRA:
			return "Extra ship"
	return "Ship"


func isCompanyShip() -> bool:
	return shipType == ShipTypes.ShipType.COMPANY

func isExtraShip() -> bool:
	return shipType == ShipTypes.ShipType.EXTRA

func isDamaged() -> bool:
	return isFlipped

func damageShip(sea_zone: String = "Unknown Sea")->void:
	if isFlipped:
		return
	self.isFlipped = true
	ActionManager.add_action(
		ActionFactory.ship_action(display_name(), sea_zone, "damaged")
	)
