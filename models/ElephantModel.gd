extends Resource
class_name ElephantModel



@export var placement: EnumTypes.ElephantPlacement
@export var current_state: StateType.StateType


@export var border_state_a: StateType.StateType
@export var border_state_b: StateType.StateType

@export var facing_state: StateType.StateType

func getTouchingLocations()-> Array[StateType.StateType]:
	var locations: Array[StateType.StateType] = []
	if is_on_border():
		locations.append(border_state_a)
		locations.append(border_state_b)
	elif is_inside_state():
		locations.append(current_state)
	return locations

func placeInCenterOf(targetLocation: StateType.StateType):
	var origin := _placement_description()
	current_state = targetLocation
	placement = EnumTypes.ElephantPlacement.IN_STATE
	ActionManager.add_action(
		ActionFactory.move_elephant_action(
			origin, StateType.name(targetLocation), "center"
		)
	)
	
	
func placeOnBorderOf(facingDirection: StateType.StateType, backDirection: StateType.StateType):
	var origin := _placement_description()
	placement = EnumTypes.ElephantPlacement.ON_BORDER	
	border_state_a =  facingDirection
	border_state_b = backDirection
	facing_state = facingDirection
	ActionManager.add_action(
		ActionFactory.move_elephant_action(
			origin,
			"%s / %s" % [StateType.name(facingDirection), StateType.name(backDirection)],
			"border"
		)
	)


func _placement_description() -> String:
	if is_inside_state():
		return StateType.name(current_state)
	if is_on_border():
		return "%s / %s" % [StateType.name(border_state_a), StateType.name(border_state_b)]
	return "unknown location"

func is_inside_state() -> bool:
	return placement == EnumTypes.ElephantPlacement.IN_STATE

func is_on_border() -> bool:
	return placement == EnumTypes.ElephantPlacement.ON_BORDER

func get_backward_state() -> StateType.StateType:
	assert(is_on_border())
	if facing_state == border_state_a:
		return border_state_b

	return border_state_a
	
func get_facing_state() -> StateType.StateType:
	assert(is_on_border())
	if facing_state == border_state_a:
		return border_state_a

	return border_state_b
