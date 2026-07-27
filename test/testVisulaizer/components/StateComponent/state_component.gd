@tool
extends Node2D
class_name StateComponent


@export var state_name: String = "":
	set(value):
		state_name = value
		if is_node_ready():
			update_ui()

@export var stateModel: StateModel:
	set(value):
		if stateModel != null and stateModel.changed.is_connected(update_ui):
			stateModel.changed.disconnect(update_ui)
		stateModel = value
		if is_node_ready():
			_connect_model()
			update_ui()

@onready var state_label: Label = $HoverArea/Label
@onready var details = $KeyValueTextComponent


func _ready() -> void:
	details.hide()
	_connect_model()
	update_ui()


func _connect_model() -> void:
	if stateModel != null and not stateModel.changed.is_connected(update_ui):
		stateModel.changed.connect(update_ui)


func update_ui() -> void:
	if not is_node_ready():
		return

	if stateModel == null:
		state_label.text = state_name if not state_name.is_empty() else "NO STATE"
		details.data_entries = {}
		return
	$HoverArea/TowerLevel.text = str(stateModel.towerLevel)
	state_label.text = state_name if not state_name.is_empty() else StateType.name(stateModel.location)
	details.data_entries = {
		"Unrest:": str(stateModel.unrest_size),
		"Commander:": _yes_no(stateModel.hasCommander),
		"Officers:": str(stateModel.officers),
		"Troops:": str(stateModel.troops),
		"Exhausted troops:": str(stateModel.exhaustedTroops),
		"Governor:": _yes_no(stateModel.hasGovenor),
		"Orders:": str(stateModel.orders.size()),
		"Sovereign:": _yes_no(stateModel.isSovereign),
		"Empire:": EnumTypes.Empires.keys()[stateModel.partOfEmpire],
		"Empire capital:": _yes_no(stateModel.isEmpireCapital),
		"Dominated:": _yes_no(stateModel.isDominated),
		"Dominated by:": _dominator_name(),
		"Company controlled:": _yes_no(stateModel.isCompanyControlled),
		"Tower level:": str(stateModel.towerLevel),
		"Rebelled:": _yes_no(stateModel.hasRebelled),
	}


func _yes_no(value: bool) -> String:
	return "Yes" if value else "No"


func _dominator_name() -> String:
	if stateModel.isDominatedBy == null:
		return "-"
	return StateType.name(stateModel.isDominatedBy.location)


func _on_hover_area_mouse_entered() -> void:
	update_ui()
	details.show()


func _on_hover_area_mouse_exited() -> void:
	details.hide()
