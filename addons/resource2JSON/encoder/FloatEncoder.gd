extends "res://addons/resource2JSON/encoder/ValueEncoder.gd"


func can_encode(value: Variant, _context: Dictionary) -> bool:
	return value is float


func encode(value: Variant, _context: Dictionary, _encode_value: Callable) -> Variant:
	if is_finite(value):
		return value
	return var_to_str(value)
