extends "res://addons/resource2JSON/decoder/ValueDecoder.gd"


func can_decode(value: Variant, _context: Dictionary) -> bool:
	return value is Dictionary


func decode(value: Variant, context: Dictionary, decode_value: Callable) -> Variant:
	var decoded := {}
	var nested_context := _without_property_context(context)
	for key in value:
		decoded[key] = decode_value.call(value[key], nested_context)
	var current_value: Variant = context.get("current_value")
	if current_value is Dictionary:
		current_value.assign(decoded)
		return current_value
	return decoded


func _without_property_context(context: Dictionary) -> Dictionary:
	var nested_context := context.duplicate()
	nested_context.erase("current_value")
	nested_context.erase("property_info")
	nested_context.erase("target_resource")
	nested_context.decode_as_resource = false
	return nested_context
