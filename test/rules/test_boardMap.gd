extends GutTest


func test_each_region_has_each_elephant_shape_at_most_once() -> void:
	var shape_counts_by_state := {}

	for border_marker in BoardMap.boardMap.elephantBorderMarker:
		if not shape_counts_by_state.has(border_marker.state):
			shape_counts_by_state[border_marker.state] = {}

		var shape_counts: Dictionary = shape_counts_by_state[border_marker.state]
		for shape in border_marker.shapes:
			if not shape_counts.has(shape):
				shape_counts[shape] = 0
			shape_counts[shape] += 1

	for state in shape_counts_by_state:
		var shape_counts: Dictionary = shape_counts_by_state[state]
		for shape in shape_counts:
			assert_lte(
				shape_counts[shape],
				1,
				"%s has duplicate Elephant shape %s" % [
					StateType.name(state),
					_shape_name(shape),
				]
			)


func _shape_name(shape: EnumTypes.ElephantMarker) -> String:
	return EnumTypes.ElephantMarker.keys()[shape]
