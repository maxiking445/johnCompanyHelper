extends RefCounted


static var VALUE_ENCODERS := [
	preload("res://addons/resource2JSON/encoder/ResourceReferenceEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/PrimitiveEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/FloatEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/StringEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/ColorEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/Vector2Encoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/Vector2iEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/Rect2Encoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/Rect2iEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/Vector3Encoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/Vector3iEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/Transform2DEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/Vector4Encoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/Vector4iEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/PlaneEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/QuaternionEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/AABBEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/BasisEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/Transform3DEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/ProjectionEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/NodePathEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/PackedArrayEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/ArrayEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/DictionaryEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/ResourceEncoder.gd").new(),
	preload("res://addons/resource2JSON/encoder/FallbackEncoder.gd").new(),
]


static func convert(resource: Resource, indent: String = "\t") -> String:
	if resource == null:
		push_error("Cannot convert a null Resource to JSON.")
		return ""

	var context := {
		"resource_ids": {},
		"next_id": 1,
	}
	return JSON.stringify(_encode_value(resource, context), indent)


static func _encode_value(value: Variant, context: Dictionary) -> Variant:
	for encoder in VALUE_ENCODERS:
		if encoder.can_encode(value, context):
			return encoder.encode(value, context, _encode_value)
	push_error("No encoder registered for Variant type %d." % typeof(value))
	return null
