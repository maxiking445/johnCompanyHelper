extends Node
class_name StateType

enum StateType {
	BOMBAY,
	MADRAS,
	HYPERBAD,
	PUNJAB,
	BENGAL,
	MARATHA,
	DELIH,
	MYSORE,
}

static func name(state: StateType.StateType) -> String:
	return StateType.StateType.keys()[state]
