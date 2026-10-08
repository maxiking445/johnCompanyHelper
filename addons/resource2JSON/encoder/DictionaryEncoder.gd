extends "res://addons/resource2JSON/encoder/ValueEncoder.gd"


func can_encode(value: Variant, _context: Dictionary) -> bool:
	return value is Dictionary


func encode(value: Variant, context: Dictionary, encode_value: Callable) -> Variant:
	var encoded := {}
	for key in value:
		encoded[str(key)] = encode_value.call(value[key], context)
	return encoded
