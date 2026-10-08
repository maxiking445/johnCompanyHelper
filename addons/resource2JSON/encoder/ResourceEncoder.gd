extends "res://addons/resource2JSON/encoder/ValueEncoder.gd"


func can_encode(value: Variant, _context: Dictionary) -> bool:
	return value is Resource


func encode(value: Variant, context: Dictionary, encode_value: Callable) -> Variant:
	var resource := value as Resource
	var resource_id: int = context.next_id
	context.next_id = resource_id + 1
	context.resource_ids[resource.get_instance_id()] = resource_id

	var json_object := {"$resourceId": resource_id}
	for property in resource.get_property_list():
		var property_name := String(property.name)
		var usage: int = property.usage
		if not usage & PROPERTY_USAGE_STORAGE:
			continue
		if not usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			continue
		json_object[property_name] = encode_value.call(resource.get(property_name), context)
	return json_object
