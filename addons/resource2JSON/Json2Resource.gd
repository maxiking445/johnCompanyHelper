extends RefCounted



static var decoders := [
	preload("res://addons/resource2JSON/decoder/DeclaredStringDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/ResourceReferenceDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/NestedResourceDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/NonFiniteFloatDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/ColorDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/Vector2Decoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/Vector2iDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/Rect2Decoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/Rect2iDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/Vector3Decoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/Vector3iDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/Transform2DDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/Vector4Decoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/Vector4iDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/PlaneDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/QuaternionDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/AABBDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/BasisDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/Transform3DDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/ProjectionDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/NodePathDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/PackedArrayDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/ArrayDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/ResourceDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/DictionaryDecoder.gd").new(),
	preload("res://addons/resource2JSON/decoder/StringDecoder.gd").new(),
]


static func decode(value: Variant, context: Dictionary) -> Variant:
	for decoder in decoders:
		if decoder.can_decode(value, context):
			return decoder.decode(value, context, decode)
	return value

static func convert(json: String, resource_type: Variant) -> Resource:
	var parser := JSON.new()
	var error := parser.parse(json)
	if error != OK:
		push_error(
			"Invalid JSON at line %d: %s"
			% [parser.get_error_line(), parser.get_error_message()]
		)
		return null

	if not parser.data is Dictionary:
		push_error("The JSON root must be an object.")
		return null

	var result := _create_target_resource(resource_type)
	if result == null:
		return null
	var context := {
		"resources": {},
		"next_resource_id": 1,
		"decode_as_resource": true,
		"target_resource": result,
	}
	return decode(parser.data, context)


static func _create_target_resource(resource_type: Variant) -> Resource:
	if resource_type is Script:
		var instance: Variant = resource_type.new()
		if instance is Resource:
			return instance
		push_error("The provided script does not create a Resource.")
		return null
	push_error("A Resource script or native class name must be provided.")
	return null
