extends "res://addons/resource2JSON/decoder/ValueDecoder.gd"


func can_decode(value: Variant, context: Dictionary) -> bool:
	return (
		value is Dictionary
		and context.get("decode_as_resource", false)
		and context.get("target_resource") is Resource
	)


func decode(value: Variant, context: Dictionary, decode_value: Callable) -> Variant:
	var properties := value as Dictionary
	var resource := context.target_resource as Resource
	_register_resource(resource, context, properties)

	for property_name in properties:
		if property_name == "$resourceId":
			continue
		_decode_property(
			resource,
			String(property_name),
			properties[property_name],
			context,
			decode_value
		)
	return resource


func _register_resource(
	resource: Resource,
	context: Dictionary,
	properties: Dictionary
) -> void:
	var resource_id := int(properties.get("$resourceId", context.resources.size() + 1))
	context.resources[resource_id] = resource


func _decode_property(
	resource: Resource,
	property_name: String,
	raw_value: Variant,
	context: Dictionary,
	decode_value: Callable
) -> void:
	var current_value: Variant = resource.get(property_name)
	var property_info := _find_property(resource, property_name)
	var property_context := context.duplicate()
	property_context.erase("target_resource")
	property_context.decode_as_resource = false
	property_context.current_value = current_value
	property_context.property_info = property_info
	resource.set(property_name, decode_value.call(raw_value, property_context))


func _find_property(resource: Resource, property_name: String) -> Dictionary:
	for property in resource.get_property_list():
		if String(property.name) == property_name:
			return property
	return {}
