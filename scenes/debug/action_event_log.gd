extends Control
class_name ActionEventLog

@onready var _action_list: VBoxContainer = (
	$PanelContainer/ScrollContainer/VBoxContainer
)

var _rendered_action_count := 0


func renderActions() -> void:
	var actions: Array[Action] = ActionManager.get_actions()
	if _rendered_action_count > actions.size():
		clear()

	for action_index in range(_rendered_action_count, actions.size()):
		var action := actions[action_index]
		var label: Label = Label.new()
		label.text = action.text
		_action_list.add_child(label)

	_rendered_action_count = actions.size()


func clear() -> void:
	for child in _action_list.get_children():
		child.free()
	_rendered_action_count = 0
