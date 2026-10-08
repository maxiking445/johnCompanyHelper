extends RefCounted
class_name JSONConverter


const ResourceToJSON := preload("res://addons/resource2JSON/Resource2Json.gd")
const JSONToResource := preload("res://addons/resource2JSON/Json2Resource.gd")


static func convert(input: Variant, resource_type: Variant = null) -> Variant:
	if input is Resource:
		return stringify(input)
	if input is String:
		return parse(input, resource_type)

	push_error("Converter input must be a Resource or a JSON String.")
	return null


static func stringify(resource: Resource, indent: String = "\t") -> String:
	return ResourceToJSON.convert(resource, indent)


static func parse(json: String, resource_type: Variant) -> Resource:
	return JSONToResource.convert(json, resource_type)


static func resource_to_json(resource: Resource, indent: String = "\t") -> String:
	return stringify(resource, indent)


static func json_to_resource(json: String, resource_type: Variant) -> Resource:
	return parse(json, resource_type)
