@abstract
class_name Action
extends Resource

@export var text: String
@export var title: String
@export var type: EnumTypes.ActionType
var eventId: int = -1
var display_text: String = ""

@export_group("Parameter Validation")

## Defines together with [member maximum_parameter_count] how many values
## [method configure] accepts.
##
## Configuration examples:
## - Exactly 2 parameters: Minimum = 2, Maximum = 2
## - 1 to 5 parameters: Minimum = 1, Maximum = 5
## - At least 10 parameters: Minimum = 10, Maximum = -1
## - Any number of parameters: Minimum = 0, Maximum = -1
@export var minimum_parameter_count: int = 0

## Maximum number of values accepted by [method configure].
## A value of -1 disables the upper limit. Other negative values are invalid.
## See [member minimum_parameter_count] for complete examples.
@export var maximum_parameter_count: int = -1


## Populates the action with named runtime values.
## Concrete actions must implement this method and call [method _format_text].
@abstract
func configure(values: Dictionary) -> void

func _format_text(values: Dictionary) -> bool:
	if not _validate_parameter_count(values.size()):
		return false
	if not _validate_placeholders(values):
		return false
	text = text.format(values)
	return true


func _validate_parameter_count(parameter_count: int) -> bool:
	if minimum_parameter_count < 0:
		push_error(
			"Action '%s' has an invalid negative minimum parameter count."
			% title
		)
		return false

	if (
		maximum_parameter_count != -1
		and maximum_parameter_count < minimum_parameter_count
	):
		push_error(
			"Action '%s' has a maximum parameter count below its minimum."
			% title
		)
		return false

	if parameter_count < minimum_parameter_count:
		push_error(
			"Action '%s' expected at least %d parameters, but received %d."
			% [title, minimum_parameter_count, parameter_count]
		)
		return false

	if maximum_parameter_count != -1 and parameter_count > maximum_parameter_count:
		push_error(
			"Action '%s' expected at most %d parameters, but received %d."
			% [title, maximum_parameter_count, parameter_count]
		)
		return false

	return true


func _validate_placeholders(values: Dictionary) -> bool:
	var placeholder_regex := RegEx.new()
	placeholder_regex.compile("\\{([A-Za-z_][A-Za-z0-9_]*)\\}")
	var placeholders: Dictionary = {}
	for regex_match in placeholder_regex.search_all(text):
		placeholders[regex_match.get_string(1)] = true

	if placeholders.size() != values.size():
		push_error(
			"Action '%s' has %d unique placeholders, but received %d values."
			% [title, placeholders.size(), values.size()]
		)
		return false

	for placeholder in placeholders:
		if not values.has(placeholder):
			push_error(
				"Action '%s' is missing a value for placeholder {%s}."
				% [title, placeholder]
			)
			return false

	return true
