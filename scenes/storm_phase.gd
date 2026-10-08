extends Control

signal completed

@export var flip_duration: float = 1.4
@export var portrait_die_size: float = 330.0
@export var landscape_die_size: float = 520.0

@onready var die: Control = $DieArea/Die
@onready var die_area: CenterContainer = $DieArea
@onready var result: VBoxContainer = $Result
@onready var heading: Label = $Margin/Layout/Heading
@onready var result_title: Label = $Result/Title
@onready var actions_heading: Label = $Result/ActionsHeading
@onready var actions: ScrollContainer = $Result/ActionList
@onready var continue_button: Button = $Margin/Layout/Continue

var game_state: GameState
var revealed := false
var roll_finished := false
var advancing := false
var rule := StormRule.new()


func _ready() -> void:
	die.pressed.connect(_reveal)
	continue_button.pressed.connect(_continue)
	var heading_settings := actions_heading.label_settings.duplicate() as LabelSettings
	heading_settings.font_size = 36
	heading_settings.outline_size = 0
	actions_heading.label_settings = heading_settings
	get_viewport().size_changed.connect(_update_layout)
	_update_layout()


func initialize(state: GameState) -> void:
	game_state = state
	heading.text = "ROUND %d · STORM" % (state.completedRounds + 1)


func _update_layout() -> void:
	var viewport_size := get_viewport_rect().size
	var portrait := viewport_size.y >= viewport_size.x
	var extent: float
	if not revealed:
		extent = minf(viewport_size.x * 0.6, viewport_size.y * 0.42)
	elif portrait:
		extent = minf(portrait_die_size, viewport_size.x * 0.58)
	else:
		extent = minf(landscape_die_size, viewport_size.y * 0.55)
	die.custom_minimum_size = Vector2.ONE * extent
	die_area.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	die_area.size = Vector2.ONE * extent
	if revealed and not portrait:
		die_area.position = Vector2(viewport_size.x * 0.72 - extent * 0.5, viewport_size.y * 0.53 - extent * 0.5)
	elif revealed:
		die_area.position = Vector2((viewport_size.x - extent) * 0.5, viewport_size.y * 0.25 - extent * 0.5)
	else:
		die_area.position = (viewport_size - Vector2.ONE * extent) * 0.5

	var scroll_size: Vector2
	var scroll_position: Vector2
	if portrait:
		scroll_size = Vector2(maxf(280.0, viewport_size.x - 40.0), viewport_size.y * 0.28)
		scroll_position = Vector2((viewport_size.x - scroll_size.x) * 0.5, viewport_size.y * 0.56)
	else:
		scroll_size = Vector2(minf(1000.0, viewport_size.x * 0.38), minf(620.0, viewport_size.y * 0.4))
		scroll_position = Vector2(maxf(24.0, viewport_size.x * 0.03), viewport_size.y * 0.45)
	result.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	result.position = Vector2(scroll_position.x, scroll_position.y - 109.0)
	result.size = Vector2(scroll_size.x, scroll_size.y + 119.0)
	actions_heading.custom_minimum_size.y = 42.0


func _reveal() -> void:
	if revealed or game_state == null:
		return
	revealed = true
	# Roll exactly once. The cube lands on this result; events wait for Continue.
	rule.execute(game_state)
	die.roll_duration = flip_duration
	await die.roll_to(rule.last_result)
	_show_result()


func _show_result() -> void:
	var zone := ""
	match rule.last_result:
		StormDice.Face.SOUTH_3: zone = "South Sea"
		StormDice.Face.EAST_2: zone = "East Sea"
		StormDice.Face.WEST_2: zone = "West Sea"
		StormDice.Face.STORMS_ALL: zone = "all three seas"
	result_title.text = "Calm seas" if zone.is_empty() else "Storm · %s" % zone
	var log_actions: Array[Action] = []
	for ship_result in rule.ship_results:
		var action := FormattedAction.new()
		action.title = "%s · Ship %d" % [ship_result.zone, ship_result.ship]
		action.type = EnumTypes.ActionType.INFO if ship_result.outcome == "escaped" else EnumTypes.ActionType.BOARD_CHANGE
		match ship_result.outcome:
			"escaped": action.text = "Roll %d · Escaped, no change" % ship_result.roll
			"damaged": action.text = "Roll %d · Flip to fatigued side" % ship_result.roll
			"sunk": action.text = "Roll %d · Return to shipyard" % ship_result.roll
		log_actions.append(action)
	if log_actions.is_empty():
		if not zone.is_empty():
			var action := FormattedAction.new()
			action.title = "No player ships in affected seas"
			action.type = EnumTypes.ActionType.INFO
			log_actions.append(action)
	result.show()
	actions_heading.visible = not log_actions.is_empty()
	actions.visible = not log_actions.is_empty()
	continue_button.show()
	continue_button.text = "Continue to %d event%s" % [game_state.eventsToDraw, "" if game_state.eventsToDraw == 1 else "s"]
	_update_layout()
	actions.display_actions(log_actions)
	roll_finished = true


func _continue() -> void:
	if not roll_finished or advancing:
		return
	advancing = true
	continue_button.disabled = true
	completed.emit()
