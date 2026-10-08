extends "res://addons/resource2JSON/encoder/ValueEncoder.gd"


func can_encode(value: Variant, _context: Dictionary) -> bool:
	return value is String or value is StringName


func encode(value: Variant, _context: Dictionary, _encode_value: Callable) -> Variant:
	return str(value)
