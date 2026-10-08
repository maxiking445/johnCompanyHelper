extends "res://addons/resource2JSON/encoder/ValueEncoder.gd"


func can_encode(value: Variant, _context: Dictionary) -> bool:
	return value == null or value is bool or value is int


func encode(value: Variant, _context: Dictionary, _encode_value: Callable) -> Variant:
	return value
