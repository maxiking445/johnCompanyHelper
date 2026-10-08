extends "res://addons/resource2JSON/decoder/ValueDecoder.gd"


func can_decode(value: Variant, context: Dictionary) -> bool:
	var current_type := typeof(context.get("current_value"))
	return (
		value is Array
		and current_type >= TYPE_PACKED_BYTE_ARRAY
		and current_type <= TYPE_PACKED_VECTOR4_ARRAY
	)


func decode(value: Variant, context: Dictionary, decode_value: Callable) -> Variant:
	var decoded: Array = []
	var nested_context := _without_property_context(context)
	for item in value:
		decoded.append(decode_value.call(item, nested_context))

	var target_type := typeof(context.current_value)
	if target_type == TYPE_PACKED_COLOR_ARRAY:
		return _to_color_array(decoded)
	return type_convert(decoded, target_type)


func _to_color_array(value: Array) -> PackedColorArray:
	var colors := PackedColorArray()
	for item in value:
		if item is Color:
			colors.append(item)
		elif item is Array and item.size() == 4:
			colors.append(Color(
				float(item[0]), float(item[1]), float(item[2]), float(item[3])
			))
	return colors


func _without_property_context(context: Dictionary) -> Dictionary:
	var nested_context := context.duplicate()
	nested_context.erase("current_value")
	nested_context.erase("property_info")
	nested_context.erase("target_resource")
	nested_context.decode_as_resource = false
	return nested_context
