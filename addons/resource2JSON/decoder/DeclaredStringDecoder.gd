extends "res://addons/resource2JSON/decoder/ValueDecoder.gd"


func can_decode(value: Variant, context: Dictionary) -> bool:
	var property_info: Dictionary = context.get("property_info", {})
	return (
		value is String
		and int(property_info.get("type", TYPE_NIL)) == TYPE_STRING
	)


func decode(value: Variant, _context: Dictionary, _decode_value: Callable) -> Variant:
	return value
