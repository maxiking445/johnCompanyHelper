extends "res://addons/resource2JSON/encoder/ValueEncoder.gd"


func can_encode(value: Variant, context: Dictionary) -> bool:
	return (
		value is Resource
		and context.resource_ids.has(value.get_instance_id())
	)


func encode(value: Variant, context: Dictionary, _encode_value: Callable) -> Variant:
	return "ResourceRef(%d)" % context.resource_ids[value.get_instance_id()]
