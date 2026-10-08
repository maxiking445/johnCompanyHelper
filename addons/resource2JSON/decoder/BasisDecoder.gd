extends "res://addons/resource2JSON/decoder/ValueDecoder.gd"


const PREFIX := "Basis("


func can_decode(value: Variant, _context: Dictionary) -> bool:
	return value is String and value.begins_with(PREFIX) and value.ends_with(")")


func decode(value: Variant, _context: Dictionary, _decode_value: Callable) -> Variant:
	var decoded: Variant = str_to_var(value)
	if decoded is Basis:
		return decoded
	return value
