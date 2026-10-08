@abstract
extends RefCounted


@abstract func can_encode(value: Variant, context: Dictionary) -> bool


@abstract func encode(
	value: Variant,
	context: Dictionary,
	encode_value: Callable
) -> Variant
