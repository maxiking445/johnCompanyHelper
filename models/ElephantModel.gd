extends Resource
class_name ElephantModel



@export var placement: EnumTypes.ElephantPlacement
@export var current_state: StateType.StateType


@export var border_state_a: StateType.StateType
@export var border_state_b: StateType.StateType

@export var facing_state: StateType.StateType


func placeInCenterOf(targetLocation: StateType.StateType):
	placement = EnumTypes.ElephantPlacement.IN_STATE
	
	
func placeOnBorderOf(facingDirection: StateType.StateType, backDirection: StateType.StateType):
	placement = EnumTypes.ElephantPlacement.ON_BORDER	
	border_state_a =  facingDirection
	border_state_b = backDirection
	facing_state = facingDirection

func is_inside_state() -> bool:
	return placement == EnumTypes.ElephantPlacement.IN_STATE

func is_on_border() -> bool:
	return placement == EnumTypes.ElephantPlacement.ON_BORDER

func get_backward_state() -> StateType.StateType:
	assert(is_on_border())
	if facing_state == border_state_a:
		return border_state_b

	return border_state_a
