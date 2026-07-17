extends Resource
class_name StateModel

@export var location: StateType.StateType

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
@export var isEmpireCapital: bool

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
	return isEmpireCapital
	
func createNewEmpire(flag: EnumTypes.Empires ):	
	partOfEmpire = flag
	isSovereign = true
	isEmpireCapital = true


func remove_empire_flag() -> void:
	partOfEmpire = EnumTypes.Empires.NONE


func become_dominated_by(state: StateModel) -> void:
	partOfEmpire = state.partOfEmpire
	isSovereign = false
	isEmpireCapital = false
	isDominated = state.isPartOfEmpire()
	isDominatedBy = state if state.isPartOfEmpire() else null


func restore_local_authority() -> void:
	resetUnrest()
	towerLevel = 1
	isCompanyControlled = false
	isSovereign = true
	isEmpireCapital = false
	isDominated = false
	isDominatedBy = null
	remove_empire_flag()


func become_sovereign_after_rebellion() -> void:
	isSovereign = true
	isEmpireCapital = false
	remove_empire_flag()
	isDominated = false
	isDominatedBy = null


func resolve_foreign_invasion(invasion_strength: int) -> void:
	remove_empire_flag()
	isCompanyControlled = false
	isSovereign = true
	isEmpireCapital = false
	isDominated = false
	isDominatedBy = null
	towerLevel = floori(invasion_strength / 2.0)


func clear_rebellion() -> void:
	hasRebelled = false
	
	
func isDominatedByState(state: StateModel):
	if !state.isSovereign:
		return false
	if isDominated && isDominatedBy == state:
		return true
	return false		
func getWritersAmountInState()-> int:
	var writers: int = 0
	for order in orders:
		if order.hasWriterOnOrder():
			writers = writers + 1
	return writers			
