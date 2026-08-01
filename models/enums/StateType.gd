extends Node
class_name StateType

enum StateType {
	BOMBAY,
	MADRAS,
	HYDERABAD,
	PUNJAB,
	BENGAL,
	MARATHA,
	DELHI,
	MYSORE,
	NONE
}

static func name(state: StateType.StateType) -> String:
	return StateType.StateType.keys()[state]
