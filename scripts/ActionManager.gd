extends Node

signal action_added(action: Action)
signal actions_cleared

var _actions: Array[Action] = []


func add_action(action: Action) -> void:
	if action == null:
		push_error("ActionManager cannot add a null action.")
		return
	_actions.append(action)
	action_added.emit(action)


func get_actions() -> Array[Action]:
	return _actions.duplicate()


func get_action(index: int) -> Action:
	if index < 0 or index >= _actions.size():
		return null
	return _actions[index]


func get_action_count() -> int:
	return _actions.size()


func clear() -> void:
	_actions.clear()
	actions_cleared.emit()


func print_actions() -> void:
	for index in _actions.size():
		var action := _actions[index]
		print("%d. [%s] %s: %s" % [index + 1, action.type, action.title, action.text])
