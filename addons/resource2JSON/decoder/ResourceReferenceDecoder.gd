extends "res://addons/resource2JSON/decoder/ValueDecoder.gd"


const PREFIX := "ResourceRef("


func can_decode(value: Variant, _context: Dictionary) -> bool:
	return value is String and value.begins_with(PREFIX) and value.ends_with(")")


func decode(value: Variant, context: Dictionary, _decode_value: Callable) -> Variant:
	var resource_id := int(value.trim_prefix(PREFIX).trim_suffix(")"))
	var resource := context.resources.get(resource_id) as Resource
	if resource != null:
		return resource
	var property_info: Dictionary = context.get("property_info", {})
	resource = _create_resource(StringName(property_info.get("class_name", "Resource")))
	context.resources[resource_id] = resource
	return resource


func _create_resource(target_class: StringName) -> Resource:
	if ClassDB.class_exists(target_class) and ClassDB.can_instantiate(target_class):
		var instance: Variant = ClassDB.instantiate(target_class)
		if instance is Resource:
			return instance
	for global_class in ProjectSettings.get_global_class_list():
		if StringName(global_class.get("class", "")) != target_class:
			continue
		var script := load(String(global_class.get("path", ""))) as Script
		if script != null:
			var instance: Variant = script.new()
			if instance is Resource:
				return instance
	return Resource.new()
