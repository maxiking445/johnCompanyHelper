extends Resource
class_name IndiaEvent

@export var eventName: String
@export var eventLocation: StateType.StateType
@export var modifier: int

@export var elephantShape: EnumTypes.ElephantMarker = EnumTypes.ElephantMarker.NONE
@export var ruleText: String
@export var rule: Rule

@export var front_sprite: CompressedTexture2D
@export var back_sprite: CompressedTexture2D
