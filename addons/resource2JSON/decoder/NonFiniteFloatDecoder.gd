extends "res://addons/resource2JSON/decoder/ValueDecoder.gd"


func can_decode(value: Variant, _context: Dictionary) -> bool:
	return value is String and value in ["inf", "inf_neg", "nan"]


func decode(value: Variant, _context: Dictionary, _decode_value: Callable) -> Variant:
	return str_to_var(value)
