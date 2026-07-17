extends Control
class_name ActionEventLog


# Called when the node enters the scene tree for the first time.
func renderActions() -> void:
	var actions: Array[Action] = ActionManager.get_actions()
	for action in actions:
		var label: Label = Label.new()
		label.text = action.text
		$PanelContainer/ScrollContainer/VScrollBar/VBoxContainer.add_child(label)


func clear():
	for child in $PanelContainer/ScrollContainer/VScrollBar/VBoxContainer.get_children():
		child.queue_free()
