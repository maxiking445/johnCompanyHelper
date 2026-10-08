extends "res://addons/resource2JSON/decoder/ValueDecoder.gd"


func can_decode(value: Variant, context: Dictionary) -> bool:
	var property_info: Dictionary = context.get("property_info", {})
	return (
		value is Dictionary
		and int(property_info.get("type", TYPE_NIL)) == TYPE_OBJECT
	)


func decode(value: Variant, context: Dictionary, decode_value: Callable) -> Variant:
	var property_info: Dictionary = context.property_info
	var target_class := StringName(property_info.get("class_name", "Resource"))
	var resource_id := int(value.get("$resourceId", 0))
	var resource := context.resources.get(resource_id) as Resource
	if resource == null:
		resource = _create_resource(target_class)
	var nested_context := _without_property_context(context)
	nested_context.decode_as_resource = true
	nested_context.target_resource = resource
	return decode_value.call(value, nested_context)


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


func _without_property_context(context: Dictionary) -> Dictionary:
	var nested_context := context.duplicate()
	nested_context.erase("current_value")
	nested_context.erase("property_info")
	return nested_context
