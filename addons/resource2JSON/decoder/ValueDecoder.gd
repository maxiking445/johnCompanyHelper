@abstract
extends RefCounted


@abstract func can_decode(value: Variant, context: Dictionary) -> bool


@abstract func decode(
	value: Variant,
	context: Dictionary,
	decode_value: Callable
) -> Variant
