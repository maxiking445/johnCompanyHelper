extends Control
class_name GameStateSetup

signal game_state_ready(game_state: GameState)

const DEFAULT_GAME_STATE := preload("res://resources/gameState/GameState1710.tres")
const MENU_SCENE := "res://scenes/menue.tscn"
const STATE_KEYS := [
	"bombay", "madras", "hyperbad", "punjab",
	"bengal", "maratha", "delhi", "mysore",
]
const STATE_TITLES := [
	"Bombay", "Madras", "Hyderabad", "Punjab",
	"Bengal", "Maratha", "Delhi", "Mysore",
]

@onready var step_label: Label = %StepLabel
@onready var title_label: Label = %TitleLabel
@onready var description_label: Label = %DescriptionLabel
@onready var form: VBoxContainer = %Form
@onready var previous_button: Button = %PreviousButton
@onready var next_button: Button = %NextButton
@onready var save_button: Button = %SaveButton
@onready var reset_button: Button = %ResetButton
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var path_label: Label = %PathLabel

var game_state: GameState
var current_step := 0
var steps: Array[Dictionary] = []


func _ready() -> void:
	_build_steps()
	_load_current()
	previous_button.pressed.connect(_previous_step)
	next_button.pressed.connect(_next_step)
	save_button.pressed.connect(_save_game_state)
	reset_button.pressed.connect(_load_default)
	%BackButton.pressed.connect(_return_to_menu)


func _build_steps() -> void:
	steps = [{
		"title": "Basic State",
		"description": "Start with the global values used by the whole game.",
		"kind": "basic",
	}]
	for index in STATE_KEYS.size():
		steps.append({
			"title": STATE_TITLES[index],
			"description": "Edit the region, its forces, status and orders.",
			"kind": "state",
			"key": STATE_KEYS[index],
		})
	steps.append({
		"title": "Elephant",
		"description": "Set the elephant placement and facing direction.",
		"kind": "resource",
		"key": "elephant",
	})
	for sea_data in [
		{"title": "West Sea", "key": "seaWest"},
		{"title": "East Sea", "key": "seaEast"},
		{"title": "South Sea", "key": "seaSouth"},
	]:
		steps.append({
			"title": sea_data.title,
			"description": "Review ships and details for this sea zone.",
			"kind": "resource",
			"key": sea_data.key,
		})
	steps.append({
		"title": "Final Details",
		"description": "Review the remaining crisis values, then save or use the state.",
		"kind": "final",
	})


func _load_default() -> void:
	game_state = DEFAULT_GAME_STATE.duplicate(true) as GameState
	current_step = 0
	path_label.text = "Loaded: res://resources/gameState/GameState1710.tres"
	_show_step()


func _load_current() -> void:
	game_state = get_node("/root/SaveGameManager").load_current()
	current_step = 0
	path_label.text = "Loaded: current saved GameState"
	_show_step()


func _show_step() -> void:
	for child in form.get_children():
		child.queue_free()

	var step: Dictionary = steps[current_step]
	step_label.text = "STEP %d OF %d" % [current_step + 1, steps.size()]
	title_label.text = step.title
	description_label.text = step.description
	progress_bar.max_value = steps.size()
	progress_bar.value = current_step + 1
	previous_button.disabled = current_step == 0
	next_button.visible = current_step < steps.size() - 1
	save_button.visible = current_step == steps.size() - 1

	match step.kind:
		"basic":
			_add_property_editor(game_state, _property_info(game_state, "companyStanding"))
			_add_property_editor(game_state, _property_info(game_state, "eventsToDraw"))
		"state":
			var state: StateModel = game_state.get(step.key)
			_add_resource_editor(state, false)
		"resource":
			_add_resource_editor(game_state.get(step.key), false)
		"final":
			_add_property_editor(
				game_state, _property_info(game_state, "hadASucessfullInvasionCrisis")
			)
			_add_property_editor(
				game_state, _property_info(game_state, "sucessFullInvasionCapital")
			)
			_add_summary()


func _add_resource_editor(resource: Resource, nested: bool) -> void:
	if resource == null:
		_add_notice("No resource assigned.")
		return
	for property in resource.get_property_list():
		if not _is_editable_property(property):
			continue
		if property.name == "isDominatedBy":
			_add_state_reference_editor(resource, property)
		else:
			_add_property_editor(resource, property, nested)


func _add_property_editor(
	target: Object, property: Dictionary, nested: bool = false
) -> void:
	if property.is_empty():
		return
	var property_name: StringName = StringName(property.name)
	var value: Variant = target.get(property_name)
	var row: Control = VBoxContainer.new() if value is Array else HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	form.add_child(row)

	var label := Label.new()
	label.text = _display_name(String(property_name))
	label.add_theme_color_override("font_color", Color("2b190f"))
	label.custom_minimum_size.x = 210.0 if not nested else 180.0
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	match property.type:
		TYPE_BOOL:
			var check := CheckBox.new()
			check.button_pressed = value
			check.toggled.connect(func(enabled: bool): target.set(property_name, enabled))
			row.add_child(check)
		TYPE_INT, TYPE_FLOAT:
			if property.hint == PROPERTY_HINT_ENUM:
				_add_enum_editor(row, target, property_name, value, property.hint_string)
			else:
				var spin := SpinBox.new()
				spin.min_value = -9999
				spin.max_value = 9999
				spin.step = 1 if property.type == TYPE_INT else 0.1
				spin.value = value
				spin.custom_minimum_size.x = 180
				spin.value_changed.connect(
					func(new_value: float):
						target.set(
							property_name,
							int(new_value) if property.type == TYPE_INT else new_value
						)
				)
				row.add_child(spin)
		TYPE_STRING, TYPE_STRING_NAME:
			var line_edit := LineEdit.new()
			line_edit.text = str(value)
			line_edit.custom_minimum_size.x = 260
			line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			line_edit.text_changed.connect(
				func(text: String):
					target.set(
						property_name,
						StringName(text) if property.type == TYPE_STRING_NAME else text
					)
			)
			row.add_child(line_edit)
		TYPE_ARRAY:
			_add_array_editor(row, target, property, value)
		TYPE_OBJECT:
			if value is Resource:
				label.add_theme_color_override("font_color", Color("71131f"))
				_add_resource_editor(value, true)
			else:
				_add_notice("No value assigned.")
		_:
			var unsupported := Label.new()
			unsupported.text = str(value)
			unsupported.modulate = Color(0.18, 0.12, 0.08, 0.65)
			row.add_child(unsupported)

	var separator := HSeparator.new()
	separator.modulate = Color(0.28, 0.13, 0.07, 0.2)
	form.add_child(separator)


func _add_enum_editor(
	row: Control,
	target: Object,
	property_name: StringName,
	value: int,
	hint_string: String
) -> void:
	var options := OptionButton.new()
	options.custom_minimum_size.x = 260
	for item in hint_string.split(","):
		var parts := item.split(":")
		options.add_item(_display_name(parts[0]))
		if parts.size() > 1:
			options.set_item_id(options.item_count - 1, int(parts[1]))
	options.select(maxi(0, options.get_item_index(value)))
	options.item_selected.connect(
		func(index: int): target.set(property_name, options.get_item_id(index))
	)
	row.add_child(options)


func _add_array_editor(
	row: VBoxContainer,
	target: Object,
	property: Dictionary,
	values: Array
) -> void:
	if values.is_empty():
		var empty := Label.new()
		empty.text = "No entries in default state"
		empty.modulate = Color(0.18, 0.12, 0.08, 0.62)
		row.add_child(empty)
		return
	for index in values.size():
		var value: Variant = values[index]
		if value is Resource:
			var panel := PanelContainer.new()
			panel.add_theme_stylebox_override("panel", _panel_style(Color("e1d2ae")))
			var content := VBoxContainer.new()
			content.add_theme_constant_override("separation", 8)
			panel.add_child(content)
			var heading := Label.new()
			heading.text = "%s %d" % [_singular(_display_name(property.name)), index + 1]
			heading.add_theme_font_size_override("font_size", 17)
			heading.add_theme_color_override("font_color", Color("71131f"))
			content.add_child(heading)
			var previous_form := form
			form = content
			_add_resource_editor(value, true)
			form = previous_form
			row.add_child(panel)
		else:
			var edit := LineEdit.new()
			edit.text = str(value)
			edit.placeholder_text = "Entry %d" % (index + 1)
			edit.text_changed.connect(
				func(text: String):
					var updated: Array = target.get(property.name)
					updated[index] = int(text) if value is int else text
					target.set(property.name, updated)
			)
			row.add_child(edit)


func _add_state_reference_editor(target: Object, property: Dictionary) -> void:
	var row := HBoxContainer.new()
	form.add_child(row)
	var label := Label.new()
	label.text = _display_name(property.name)
	label.add_theme_color_override("font_color", Color("2b190f"))
	label.custom_minimum_size.x = 210
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var options := OptionButton.new()
	options.custom_minimum_size.x = 260
	options.add_item("None", -1)
	var selected := 0
	for index in STATE_KEYS.size():
		options.add_item(STATE_TITLES[index], index)
		if target.get(property.name) == game_state.get(STATE_KEYS[index]):
			selected = index + 1
	options.select(selected)
	options.item_selected.connect(
		func(index: int):
			target.set(
				property.name,
				null if index == 0 else game_state.get(STATE_KEYS[index - 1])
			)
	)
	row.add_child(options)
	form.add_child(HSeparator.new())


func _add_summary() -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(Color("e1d2ae")))
	var summary := VBoxContainer.new()
	summary.add_theme_constant_override("separation", 8)
	panel.add_child(summary)
	var heading := Label.new()
	heading.text = "Ready to use"
	heading.add_theme_font_size_override("font_size", 20)
	heading.add_theme_color_override("font_color", Color("71131f"))
	summary.add_child(heading)
	var info := Label.new()
	info.text = (
		"All %d regions, the elephant and 3 sea zones were loaded from the "
		+ "default 1710 state. Save creates user://custom_game_state.tres "
		+ "and emits game_state_ready."
	) % STATE_KEYS.size()
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_theme_color_override("font_color", Color("2b190f"))
	summary.add_child(info)
	form.add_child(panel)


func _add_notice(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.modulate = Color(0.18, 0.12, 0.08, 0.65)
	form.add_child(label)


func _previous_step() -> void:
	current_step = maxi(0, current_step - 1)
	_show_step()


func _next_step() -> void:
	current_step = mini(steps.size() - 1, current_step + 1)
	_show_step()


func _save_game_state() -> void:
	var error: Error = get_node("/root/SaveGameManager").save_current(game_state)
	if error == OK:
		path_label.text = "Current GameState saved"
		save_button.text = "Saved"
		game_state_ready.emit(game_state)
		get_tree().change_scene_to_file(MENU_SCENE)
	else:
		path_label.text = "Could not save GameState (error %d)" % error


func _return_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)


func _is_editable_property(property: Dictionary) -> bool:
	return (
		property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE
		and property.usage & PROPERTY_USAGE_STORAGE
		and not String(property.name).begins_with("_")
	)


func _property_info(target: Object, property_name: String) -> Dictionary:
	for property in target.get_property_list():
		if property.name == property_name:
			return property
	return {}


func _display_name(raw_name: String) -> String:
	var result := raw_name.replace("_", " ")
	var output := ""
	for character in result:
		if character == character.to_upper() and character != character.to_lower():
			output += " "
		output += character
	return output.strip_edges().capitalize()


func _singular(word: String) -> String:
	return word.left(-1) if word.ends_with("s") else word


func _panel_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	return style
