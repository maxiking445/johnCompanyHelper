extends Node

const SAVE_PATH := "user://current_game_state.tres"
const DEFAULT_GAME_STATE := preload("res://resources/gameState/GameState1710.tres")


func load_current() -> GameState:
	if ResourceLoader.exists(SAVE_PATH):
		var loaded := ResourceLoader.load(SAVE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
		if loaded is GameState:
			return (loaded as GameState).duplicate(true)
	return create_default()


func create_default() -> GameState:
	return DEFAULT_GAME_STATE.duplicate(true) as GameState


func reset_to_default() -> GameState:
	var default_state := create_default()
	save_current(default_state)
	return default_state


func save_current(game_state: GameState) -> Error:
	if game_state == null:
		push_error("Cannot save an empty GameState.")
		return ERR_INVALID_DATA
	return ResourceSaver.save(game_state.duplicate(true), SAVE_PATH)


func has_progress() -> bool:
	if not ResourceLoader.exists(SAVE_PATH):
		return false
	return not is_default(load_current())


func is_default(game_state: GameState) -> bool:
	if game_state == null:
		return true
	return _values_equal(game_state, DEFAULT_GAME_STATE, 0)


func _values_equal(left: Variant, right: Variant, depth: int) -> bool:
	if depth > 24 or typeof(left) != typeof(right):
		return false
	if left is Resource:
		if right == null:
			return false
		var left_resource := left as Resource
		var right_resource := right as Resource
		if left_resource.get_script() != right_resource.get_script():
			return false
		for property in left_resource.get_property_list():
			if not _is_saved_script_property(property):
				continue
			var property_name: StringName = property.name
			if not _values_equal(
				left_resource.get(property_name),
				right_resource.get(property_name),
				depth + 1
			):
				return false
		return true
	if left is Array:
		if left.size() != right.size():
			return false
		for index in left.size():
			if not _values_equal(left[index], right[index], depth + 1):
				return false
		return true
	if left is Dictionary:
		return left == right
	if left is float:
		return is_equal_approx(left, right)
	return left == right


func _is_saved_script_property(property: Dictionary) -> bool:
	return (
		property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE
		and property.usage & PROPERTY_USAGE_STORAGE
		and not String(property.name).begins_with("_")
	)
