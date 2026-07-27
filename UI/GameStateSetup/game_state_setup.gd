extends Control
class_name GameStateSetup

signal game_state_ready(game_state: GameState)

const DEFAULT_GAME_STATE := preload("res://resources/gameState/GameState1710.tres")
const MENU_SCENE := "res://scenes/menue.tscn"
const MENU_BUTTON_THEME := preload("res://scenes/component/button/menueButton.tres")
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
@onready var json_transfer: Node = %GameStateJsonTransfer

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
	%DownloadJsonButton.pressed.connect(_download_json)
	%UploadJsonButton.pressed.connect(_upload_json)
	json_transfer.import_completed.connect(_on_json_imported)
	json_transfer.export_completed.connect(_on_json_exported)
	json_transfer.transfer_failed.connect(_on_json_transfer_failed)


func _build_steps() -> void:
	steps = []
	for index in STATE_KEYS.size():
		steps.append({
			"title": STATE_TITLES[index],
			"description": "Edit the region's forces, government and status.",
			"kind": "state",
			"key": STATE_KEYS[index],
		})
	steps.append({
		"title": "Elephant",
		"description": "Set the elephant placement and facing direction.",
		"kind": "resource",
		"key": "elephant",
	})
	steps.append({
		"title": "Ships",
		"description": "Edit all ships by sea zone, then save the current GameState.",
		"kind": "ships",
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
		"state":
			var state: StateModel = game_state.get(step.key)
			_add_resource_editor(state, false)
		"resource":
			_add_resource_editor(game_state.get(step.key), false)
		"ships":
			_add_ship_sections()


func _add_ship_sections() -> void:
	for sea_data in [
		{"title": "West Sea", "key": "seaWest"},
		{"title": "East Sea", "key": "seaEast"},
		{"title": "South Sea", "key": "seaSouth"},
	]:
		var sea: SeaModel = game_state.get(sea_data.key)
		var header := HBoxContainer.new()
		header.add_theme_constant_override("separation", 12)
		form.add_child(header)
		var heading := Label.new()
		heading.text = sea_data.title
		heading.add_theme_font_size_override("font_size", 21)
		heading.add_theme_color_override("font_color", Color("71131f"))
		heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		header.add_child(heading)
		var add_button := Button.new()
		add_button.text = "Add Ship"
		add_button.theme = MENU_BUTTON_THEME
		add_button.add_theme_font_size_override("font_size", 19)
		add_button.pressed.connect(_add_ship.bind(sea))
		header.add_child(add_button)
		var rule := HSeparator.new()
		rule.modulate = Color(0.43, 0.055, 0.075, 0.45)
		form.add_child(rule)
		_add_ship_list(sea)


func _add_ship_list(sea: SeaModel) -> void:
	if sea.ships.is_empty():
		var empty := Label.new()
		empty.text = "No ships in this sea"
		empty.modulate = Color(0.18, 0.12, 0.08, 0.62)
		form.add_child(empty)
		return
	for index in sea.ships.size():
		var ship := sea.ships[index]
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", _panel_style(Color("e1d2ae")))
		var content := VBoxContainer.new()
		content.add_theme_constant_override("separation", 8)
		panel.add_child(content)

		var header := HBoxContainer.new()
		content.add_child(header)
		var title := Label.new()
		title.text = "Ship %d" % (index + 1)
		title.add_theme_font_size_override("font_size", 17)
		title.add_theme_color_override("font_color", Color("71131f"))
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		header.add_child(title)
		var remove_button := Button.new()
		remove_button.text = "Remove"
		remove_button.theme = MENU_BUTTON_THEME
		remove_button.add_theme_font_size_override("font_size", 18)
		remove_button.pressed.connect(_remove_ship.bind(sea, index))
		header.add_child(remove_button)

		var previous_form := form
		form = content
		_add_resource_editor(ship, true)
		form = previous_form
		form.add_child(panel)


func _add_ship(sea: SeaModel) -> void:
	var ship := ShipModel.new()
	ship.shipType = ShipTypes.ShipType.PLAYER
	sea.ships.append(ship)
	_show_step()


func _remove_ship(sea: SeaModel, index: int) -> void:
	if index < 0 or index >= sea.ships.size():
		return
	sea.ships.remove_at(index)
	_show_step()


func _add_resource_editor(resource: Resource, nested: bool) -> void:
	if resource == null:
		_add_notice("No resource assigned.")
		return
	for property in resource.get_property_list():
		if not _is_editable_property(property):
			continue
		if (
			resource is StateModel
			and property.name in [&"orders", &"is_connected_to"]
		):
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


func _download_json() -> void:
	json_transfer.show_export_dialog(game_state)


func _upload_json() -> void:
	json_transfer.show_import_dialog()


func _on_json_imported(imported_game_state: GameState, source_path: String) -> void:
	game_state = imported_game_state
	current_step = 0
	var save_error: Error = get_node("/root/SaveGameManager").save_current(game_state)
	if save_error != OK:
		path_label.text = "JSON loaded, but current save could not be updated"
	else:
		path_label.text = "Imported and set current save: %s" % source_path
	_show_step()


func _on_json_exported(target_path: String) -> void:
	path_label.text = "JSON exported: %s" % target_path


func _on_json_transfer_failed(message: String) -> void:
	path_label.text = message
	push_error(message)


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
