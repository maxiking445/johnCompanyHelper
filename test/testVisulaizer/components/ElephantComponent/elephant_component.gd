@tool
extends Node2D
class_name ElephantComponent


## The elephant artwork points towards local up in its default orientation.
const HEAD_ROTATION_OFFSET := PI / 2.0


func face_global_position(target_position: Vector2) -> void:
	var direction := target_position - global_position
	if direction.is_zero_approx():
		return
	global_rotation = direction.angle() + HEAD_ROTATION_OFFSET
