extends "res://addons/resource2JSON/encoder/ValueEncoder.gd"


func can_encode(value: Variant, _context: Dictionary) -> bool:
	var value_type := typeof(value)
	return value_type >= TYPE_PACKED_BYTE_ARRAY and value_type <= TYPE_PACKED_VECTOR4_ARRAY


func encode(value: Variant, context: Dictionary, encode_value: Callable) -> Variant:
	var encoded: Array = []
	for item in value:
		encoded.append(encode_value.call(item, context))
	return encoded
