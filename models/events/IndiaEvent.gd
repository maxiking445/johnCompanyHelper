extends Resource
class_name IndiaEvent

@export var eventName: String
@export var eventLocation: StateType.StateType
@export var modifier: int
# Index of the border matching the tile's circle/triangle/square symbol.
# StateModel.is_connected_to must list borders clockwise from that reference.
@export var elephantBorderIndex: int = 0
@export var ruleText: String
@export var rule: Rule
