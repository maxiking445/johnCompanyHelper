extends "res://addons/resource2JSON/decoder/ValueDecoder.gd"


func can_decode(value: Variant, _context: Dictionary) -> bool:
	return value is Array


func decode(value: Variant, context: Dictionary, decode_value: Callable) -> Variant:
	var decoded: Array = []
	var nested_context := _without_property_context(context)
	var current_value: Variant = context.get("current_value")
	for item in value:
		var item_context := nested_context
		if item is Dictionary and current_value is Array:
			var item_resource := _create_typed_item(current_value)
			if item_resource != null:
				item_context = nested_context.duplicate()
				item_context.decode_as_resource = true
				item_context.target_resource = item_resource
		decoded.append(decode_value.call(item, item_context))
	if current_value is Array:
		current_value.assign(decoded)
		return current_value
	return decoded


func _create_typed_item(array: Array) -> Resource:
	if not array.is_typed() or array.get_typed_builtin() != TYPE_OBJECT:
		return null
	var script := array.get_typed_script() as Script
	if script != null:
		var instance: Variant = script.new()
		if instance is Resource:
			return instance
	var native_class := array.get_typed_class_name()
	if ClassDB.class_exists(native_class) and ClassDB.can_instantiate(native_class):
		var instance: Variant = ClassDB.instantiate(native_class)
		if instance is Resource:
			return instance
	return null


func _without_property_context(context: Dictionary) -> Dictionary:
	var nested_context := context.duplicate()
	nested_context.erase("current_value")
	nested_context.erase("property_info")
	nested_context.erase("target_resource")
	nested_context.decode_as_resource = false
	return nested_context
