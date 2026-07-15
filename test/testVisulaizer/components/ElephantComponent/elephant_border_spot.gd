@tool
extends Node2D
class_name ElephantBorderSpot


@export var borderA: StateType.StateType
@export var borderB: StateType.StateType

@export var elephantIsHere: bool = false:
	set(value):
		elephantIsHere = value
		_update_visibility()

@onready var elephant_component: ElephantComponent = $ElephantComponent


func _ready() -> void:
	_update_visibility()


func matches_border(state_a: StateType.StateType, state_b: StateType.StateType) -> bool:
	return (
		(borderA == state_a and borderB == state_b)
		or (borderA == state_b and borderB == state_a)
	)


func show_elephant_facing(target_position: Vector2) -> void:
	elephantIsHere = true
	var elephant := get_node_or_null("ElephantComponent") as ElephantComponent
	if elephant != null:
		elephant.face_global_position(target_position)


func show_elephant() -> void:
	elephantIsHere = true


func hide_elephant() -> void:
	elephantIsHere = false


func _update_visibility() -> void:
	var elephant := get_node_or_null("ElephantComponent") as ElephantComponent
	if elephant == null:
		return

	elephant.visible = elephantIsHere
