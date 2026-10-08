extends "res://addons/resource2JSON/encoder/ValueEncoder.gd"


func can_encode(value: Variant, _context: Dictionary) -> bool:
	return value is Array


func encode(value: Variant, context: Dictionary, encode_value: Callable) -> Variant:
	var encoded: Array = []
	for item in value:
		encoded.append(encode_value.call(item, context))
	return encoded
