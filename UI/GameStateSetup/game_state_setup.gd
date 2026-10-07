extends Control
class_name GameStateSetup

signal game_state_ready(game_state: GameState)

const MENU_SCENE := "res://scenes/menue.tscn"
const FIELD_PANEL_SCENE := preload("res://UI/GameStateSetup/components/PropertyFieldPanel.tscn")
const BOOLEAN_FIELD_SCENE := preload("res://UI/GameStateSetup/components/BooleanField.tscn")
const NUMBER_STEPPER_SCENE := preload("res://UI/GameStateSetup/components/NumberStepper.tscn")
const TEXT_FIELD_SCENE := preload("res://UI/GameStateSetup/components/TextField.tscn")
const DROPDOWN_FIELD_SCENE := preload("res://UI/GameStateSetup/components/DropdownField.tscn")
const RESOURCE_CARD_SCENE := preload("res://UI/GameStateSetup/components/ResourceCard.tscn")
const SHIP_SECTION_SCENE := preload("res://UI/GameStateSetup/components/ShipSeaSection.tscn")
const FORM_NOTICE_SCENE := preload("res://UI/GameStateSetup/components/FormNotice.tscn")
const STATE_KEYS := [
	"bombay", "madras", "hyderabad", "punjab",
	"bengal", "maratha", "delhi", "mysore",
]
const STATE_TITLES := [
	"Bombay", "Madras", "Hyderabad", "Punjab",
	"Bengal", "Maratha", "Delhi", "Mysore",
]
const SCROLL_GESTURE_DEADZONE := 14.0
const SCROLL_GESTURE_DIRECTION_RATIO := 1.15
const SCROLL_WHEEL_STEP := 100

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
@onready var margin: MarginContainer = $Margin
@onready var scroll: ScrollContainer = $Margin/Card/Layout/Scroll
@onready var navigation_spacer: Control = %NavigationSpacer
@onready var download_button: Button = %DownloadJsonButton
@onready var upload_button: Button = %UploadJsonButton
@onready var back_button: Button = %BackButton

var game_state: GameState
var current_step := 0
var steps: Array[Dictionary] = []
@onready var default_picker: DefaultGameStatePicker = $DefaultGameStatePicker
var compact_layout := false
var scroll_pointer_type := 0
var scroll_touch_index := -1
var scroll_touch_start := Vector2.ZERO
var scroll_touch_last := Vector2.ZERO
var scroll_gesture_axis := 0


func _ready() -> void:
	_build_steps()
	_load_current()
	previous_button.pressed.connect(_previous_step)
	next_button.pressed.connect(_next_step)
	save_button.pressed.connect(_save_game_state)
	reset_button.pressed.connect(_show_default_picker)
	default_picker.game_state_selected.connect(_on_default_game_state_selected)
	%BackButton.pressed.connect(_return_to_menu)
	%DownloadJsonButton.pressed.connect(_download_json)
	%UploadJsonButton.pressed.connect(_upload_json)
	json_transfer.import_completed.connect(_on_json_imported)
	json_transfer.export_completed.connect(_on_json_exported)
	json_transfer.transfer_failed.connect(_on_json_transfer_failed)
	_update_responsive_layout()
	get_viewport().size_changed.connect(_update_responsive_layout)


func _update_responsive_layout() -> void:
	var viewport_size := get_viewport_rect().size
	var was_compact := compact_layout
	compact_layout = viewport_size.x < 1050.0 or viewport_size.x < viewport_size.y
	var side_margin := clampf(viewport_size.x * 0.035, 18.0, 56.0)
	var vertical_margin := clampf(viewport_size.y * 0.035, 20.0, 42.0)
	margin.offset_left = side_margin
	margin.offset_right = -side_margin
	margin.offset_top = vertical_margin
	margin.offset_bottom = -vertical_margin
	step_label.add_theme_font_size_override("font_size", 29 if compact_layout else 32)
	title_label.add_theme_font_size_override("font_size", 48 if compact_layout else 60)
	description_label.add_theme_font_size_override("font_size", 29 if compact_layout else 34)
	path_label.add_theme_font_size_override("font_size", 25 if compact_layout else 29)
	navigation_spacer.visible = not compact_layout
	var button_height := 96.0 if compact_layout else 88.0
	for button in [download_button, upload_button, reset_button, back_button,
		previous_button, next_button, save_button]:
		button.custom_minimum_size.y = button_height
		button.add_theme_font_size_override("font_size", 30 if compact_layout else 35)
	for button in [download_button, upload_button]:
		button.custom_minimum_size.x = button_height
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	reset_button.custom_minimum_size.x = 230.0 if compact_layout else 210.0
	reset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL if compact_layout else Control.SIZE_SHRINK_CENTER
	for button in [back_button, previous_button, next_button, save_button]:
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL if compact_layout else Control.SIZE_SHRINK_CENTER
	if compact_layout != was_compact and game_state != null:
		_show_step()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			if scroll_pointer_type == 0:
				_start_scroll_gesture(touch.position, 1, touch.index)
		elif scroll_pointer_type == 1 and touch.index == scroll_touch_index:
			_finish_scroll_gesture(touch.position)
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if scroll_pointer_type == 1 and drag.index == scroll_touch_index:
			_update_scroll_gesture(drag.position)
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			if scroll.visible and scroll.get_global_rect().has_point(mouse.position):
				var direction := -1 if mouse.button_index == MOUSE_BUTTON_WHEEL_UP else 1
				scroll.scroll_vertical += direction * SCROLL_WHEEL_STEP
				get_viewport().set_input_as_handled()
			elif mouse.button_index == MOUSE_BUTTON_LEFT:
				if mouse.pressed and scroll_pointer_type == 0:
					_start_scroll_gesture(mouse.position, 2)
				elif not mouse.pressed and scroll_pointer_type == 2:
					_finish_scroll_gesture(mouse.position)
	elif event is InputEventMouseMotion and scroll_pointer_type == 2:
		var motion := event as InputEventMouseMotion
		if motion.button_mask & MOUSE_BUTTON_MASK_LEFT:
			_update_scroll_gesture(motion.position)


func _start_scroll_gesture(point: Vector2, pointer_type: int, touch_index: int = -1) -> void:
	if not scroll.visible or not scroll.get_global_rect().has_point(point):
		return
	if is_instance_valid(default_picker) and default_picker.visible:
		return
	var scrollbar := scroll.get_v_scroll_bar()
	if scrollbar.visible and scrollbar.get_global_rect().has_point(point):
		return
	scroll_pointer_type = pointer_type
	scroll_touch_index = touch_index
	scroll_touch_start = point
	scroll_touch_last = point
	scroll_gesture_axis = 0


func _update_scroll_gesture(point: Vector2) -> void:
	var movement := point - scroll_touch_start
	if scroll_gesture_axis == 0 and movement.length() >= SCROLL_GESTURE_DEADZONE:
		if absf(movement.y) > absf(movement.x) * SCROLL_GESTURE_DIRECTION_RATIO:
			scroll_gesture_axis = 1
		elif absf(movement.x) > absf(movement.y) * SCROLL_GESTURE_DIRECTION_RATIO:
			scroll_gesture_axis = 2
	if scroll_gesture_axis == 1:
		scroll.scroll_vertical -= roundi(point.y - scroll_touch_last.y)
		get_viewport().set_input_as_handled()
	scroll_touch_last = point


func _finish_scroll_gesture(point: Vector2) -> void:
	_update_scroll_gesture(point)
	if scroll_gesture_axis == 1:
		get_viewport().set_input_as_handled()
	scroll_pointer_type = 0
	scroll_touch_index = -1
	scroll_gesture_axis = 0


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


func _show_default_picker() -> void:
	default_picker.open()


func _on_default_game_state_selected(
	selected_game_state: GameState, scenario: String
) -> void:
	game_state = selected_game_state
	current_step = 0
	path_label.text = "Loaded: res://resources/gameState/GameState%s.tres" % scenario
	_show_step()


func _load_current() -> void:
	game_state = get_node("/root/SaveGameManager").load_current()
	current_step = 0
	path_label.text = "Loaded: current saved GameState"
	_show_step()


func _show_step() -> void:
	for child in form.get_children():
		child.queue_free()
	scroll.scroll_vertical = 0

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
		var section := SHIP_SECTION_SCENE.instantiate()
		form.add_child(section)
		section.configure(sea_data.title)
		section.add_button.pressed.connect(_add_ship.bind(sea))
		_add_ship_list(sea)


func _add_ship_list(sea: SeaModel) -> void:
	if sea.ships.is_empty():
		form.add_child(_make_notice("No ships in this sea", 31, 0.62))
		return
	for index in sea.ships.size():
		var ship := sea.ships[index]
		var card := RESOURCE_CARD_SCENE.instantiate()
		form.add_child(card)
		card.configure("Ship %d" % (index + 1), true)
		card.remove_button.pressed.connect(_remove_ship.bind(sea, index))

		var previous_form := form
		form = card.content
		_add_resource_editor(ship, true)
		form = previous_form


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
	var panel: PanelContainer = FIELD_PANEL_SCENE.instantiate()
	var is_array: bool = value is Array
	var has_label: bool = property.type != TYPE_BOOL
	form.add_child(panel)
	panel.call("configure", compact_layout or is_array, compact_layout, is_array, has_label,
		_display_name(String(property_name)), nested)
	var slot: Control = panel.call("get_field_slot")

	match property.type:
		TYPE_BOOL:
			var boolean_field: HBoxContainer = BOOLEAN_FIELD_SCENE.instantiate()
			slot.add_child(boolean_field)
			boolean_field.configure(value, compact_layout)
			boolean_field.set_label(_display_name(String(property_name)))
			boolean_field.value_changed.connect(
				func(enabled: bool): target.set(property_name, enabled)
			)
		TYPE_INT, TYPE_FLOAT:
			if property.hint == PROPERTY_HINT_ENUM:
				_add_enum_editor(slot, target, property_name, value, property.hint_string)
			else:
				var number_field: HBoxContainer = NUMBER_STEPPER_SCENE.instantiate()
				slot.add_child(number_field)
				number_field.configure(value, property.type == TYPE_INT, compact_layout)
				number_field.value_changed.connect(
					func(new_value: float):
						target.set(
							property_name,
							int(new_value) if property.type == TYPE_INT else new_value
						)
				)
		TYPE_STRING, TYPE_STRING_NAME:
			var text_field: LineEdit = TEXT_FIELD_SCENE.instantiate()
			slot.add_child(text_field)
			text_field.configure(str(value), compact_layout)
			text_field.text_changed.connect(
				func(text: String):
					target.set(
						property_name,
						StringName(text) if property.type == TYPE_STRING_NAME else text
					)
			)
		TYPE_ARRAY:
			_add_array_editor(panel.get_node("VerticalColumn"), target, property, value)
		TYPE_OBJECT:
			if value is Resource:
				panel.call("style_label", 31, Color("71131f"))
				_add_resource_editor(value, true)
			else:
				_add_notice("No value assigned.")
		_:
			var unsupported := _make_notice(str(value), 32, 0.65)
			slot.add_child(unsupported)


func _add_enum_editor(
	row: Control,
	target: Object,
	property_name: StringName,
	value: int,
	hint_string: String
) -> void:
	var options: OptionButton = DROPDOWN_FIELD_SCENE.instantiate()
	row.add_child(options)
	options.configure(compact_layout)
	for item in hint_string.split(","):
		var parts := item.split(":")
		options.add_item(_display_name(parts[0]))
		if parts.size() > 1:
			options.set_item_id(options.item_count - 1, int(parts[1]))
	options.select(maxi(0, options.get_item_index(value)))
	options.item_selected.connect(
		func(index: int): target.set(property_name, options.get_item_id(index))
	)


func _add_array_editor(
	row: VBoxContainer,
	target: Object,
	property: Dictionary,
	values: Array
) -> void:
	if values.is_empty():
		row.add_child(_make_notice("No entries in default state", 31, 0.62))
		return
	for index in values.size():
		var value: Variant = values[index]
		if value is Resource:
			var card: PanelContainer = RESOURCE_CARD_SCENE.instantiate()
			var title := "%s %d" % [_singular(_display_name(property.name)), index + 1]
			row.add_child(card)
			card.configure(title, false)
			var previous_form := form
			form = card.content
			_add_resource_editor(value, true)
			form = previous_form
		else:
			var edit: LineEdit = TEXT_FIELD_SCENE.instantiate()
			row.add_child(edit)
			edit.configure(str(value), compact_layout, "Entry %d" % (index + 1), value is int)
			edit.text_changed.connect(
				func(text: String):
					if value is int and not text.is_valid_int():
						return
					var updated: Array = target.get(property.name)
					updated[index] = int(text) if value is int else text
					target.set(property.name, updated)
			)


func _add_state_reference_editor(target: Object, property: Dictionary) -> void:
	var panel: PanelContainer = FIELD_PANEL_SCENE.instantiate()
	form.add_child(panel)
	panel.call("configure", compact_layout, compact_layout, false, true,
		_display_name(property.name))
	var options: OptionButton = DROPDOWN_FIELD_SCENE.instantiate()
	(panel.call("get_field_slot") as Control).add_child(options)
	options.configure(compact_layout)
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


func _add_notice(text: String) -> void:
	form.add_child(_make_notice(text, 32, 0.65))


func _make_notice(text: String, font_size: int, opacity: float) -> Label:
	var notice: Label = FORM_NOTICE_SCENE.instantiate()
	notice.configure(text, font_size, opacity)
	return notice


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
