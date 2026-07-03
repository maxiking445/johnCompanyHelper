extends Resource
class_name StateModel

@export var location: StateType.StateType
@export var writers: int
@export var unrest_size: int
@export var hasCommander: bool
@export var officers: int
@export var troops: int
@export var exhaustedTroops: int
@export var hasGovenor: bool
@export var treasury_size: int
@export var orders: Array[OrderModel]
@export var is_connected_to: Array[StateType.StateType]
@export var isSovereign: bool
@export var partOfEmpire: EnumTypes.Empires = EnumTypes.Empires.NONE
@export var isSovereignCapital: bool

@export var isDominated: bool
@export var isDominatedBy: StateModel
@export var isCompanyControlled: bool
@export var towerLevel: int
@export var trophyToken: int
@export var hasRebelled: bool = false

func addThropyToken():
	trophyToken = trophyToken + 1

func addTowerLevel():
	towerLevel = towerLevel + 1
	
func removeTowerLevel():
	towerLevel = towerLevel - 1

func resetUnrest():
	unrest_size = 0

func exhaustTroops(number: int):
	exhaustedTroops = exhaustedTroops + number
	
func removeOfficer():
	officers = officers -1	

func stateHasRebelled():
	hasRebelled = true
	
func isPartOfEmpire() -> bool:	
	return partOfEmpire != EnumTypes.Empires.NONE
	
func hasSovereignCapital() -> bool:	
	return isSovereignCapital
	
func createNewEmpire(flag: EnumTypes.Empires ):	
	partOfEmpire = flag
	isSovereign = true
	isSovereignCapital = true
