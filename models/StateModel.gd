extends Resource
class_name StateModel

@export var location: StateType.StateType

@export var unrest_size: int
## The control token above a President's box assigns this region to that Presidency.
@export_enum("None", "Bombay", "Madras", "Bengal") var presidency: int = 0
@export var hasGovernor: bool
@export var orders: Array[OrderModel]
@export var is_connected_to: Array[StateType.StateType]
@export var isSovereign: bool
@export var partOfEmpire: EnumTypes.Empires = EnumTypes.Empires.NONE
@export var isEmpireCapital: bool

@export var isDominated: bool
@export var isDominatedBy: StateModel
@export var isCompanyControlled: bool
@export var towerLevel: int
@export var hasRebelled: bool = false

func addTowerLevel():
	var old_value := towerLevel
	towerLevel = towerLevel + 1
	ActionManager.add_action(
		ActionFactory.change_tower_level_action(_display_name(), old_value, towerLevel)
	)
	
func removeTowerLevel():
	var old_value := towerLevel
	towerLevel = towerLevel - 1
	ActionManager.add_action(
		ActionFactory.change_tower_level_action(_display_name(), old_value, towerLevel)
	)

func resetUnrest():
	var old_value := unrest_size
	unrest_size = 0
	if old_value != unrest_size:
		ActionManager.add_action(
			ActionFactory.change_unrest_action(_display_name(), old_value, unrest_size)
		)


func change_unrest(amount: int) -> void:
	var old_value := unrest_size
	unrest_size += amount
	if old_value != unrest_size:
		ActionManager.add_action(
			ActionFactory.change_unrest_action(_display_name(), old_value, unrest_size)
		)


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
	ActionManager.add_action(
		ActionFactory.create_empire_action(_empire_name(flag), _display_name())
	)


func remove_empire_flag() -> void:
	var removed_empire := partOfEmpire
	partOfEmpire = EnumTypes.Empires.NONE
	if removed_empire != EnumTypes.Empires.NONE:
		ActionManager.add_action(
			ActionFactory.remove_empire_flag_action(
				_empire_name(removed_empire), _display_name()
			)
		)


func become_dominated_by(state: StateModel) -> void:
	partOfEmpire = state.partOfEmpire
	isSovereign = false
	isEmpireCapital = false
	isDominated = state.isPartOfEmpire()
	isDominatedBy = state if state.isPartOfEmpire() else null
	ActionManager.add_action(
		ActionFactory.dominate_state_action(_display_name(), state._display_name())
	)


func restore_local_authority() -> void:
	resetUnrest()
	presidency = 0
	towerLevel = 1
	isCompanyControlled = false
	isSovereign = true
	isEmpireCapital = false
	isDominated = false
	isDominatedBy = null
	remove_empire_flag()
	ActionManager.add_action(
		ActionFactory.restore_local_authority_action(_display_name(), towerLevel)
	)


func become_sovereign_after_rebellion() -> void:
	isSovereign = true
	isEmpireCapital = false
	remove_empire_flag()
	isDominated = false
	isDominatedBy = null
	ActionManager.add_action(ActionFactory.restore_sovereignty_action(_display_name()))


func resolve_foreign_invasion(invasion_strength: int) -> void:
	var old_tower_level := towerLevel
	remove_empire_flag()
	isCompanyControlled = false
	isSovereign = true
	isEmpireCapital = false
	isDominated = false
	isDominatedBy = null
	towerLevel = floori(invasion_strength / 2.0)
	ActionManager.add_action(ActionFactory.restore_sovereignty_action(_display_name()))
	ActionManager.add_action(
		ActionFactory.change_tower_level_action(
			_display_name(), old_tower_level, towerLevel
		)
	)


func clear_rebellion() -> void:
	hasRebelled = false


func _display_name() -> String:
	return StateType.name(location)


func _empire_name(empire: EnumTypes.Empires) -> String:
	return EnumTypes.Empires.keys()[empire]
	
	
func isDominatedByState(state: StateModel):
	if !state.isSovereign:
		return false
	if isDominated && isDominatedBy == state:
		return true
	return false		
