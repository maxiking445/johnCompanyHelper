@tool
extends Node2D
class_name UIGameStateVisualiser

const MAIN := preload("res://scenes/main.gd")
const INDIA_EVENTS: IndiaEvents = preload("res://resources/events/IndiaEvents.tres")

@onready var event_dropdown: MenuButton = $HBoxContainer/EventListDropDown
@onready var location_dropdown: MenuButton = $HBoxContainer/TargetLocationDropDown

var _events: Array[IndiaEvent] = []
var _selected_event := 0
var _selected_location: StateType.StateType = StateType.StateType.BOMBAY

@export var game_state: GameState:
	set(value):
		game_state = value
		if is_node_ready() and not _showing_expected:
			update_components()

@export var expected_game_state: GameState:
	set(value):
		expected_game_state = value
		if is_node_ready() and _showing_expected:
			update_components()

var _showing_expected := false


func _ready() -> void:
	_initialize_dropdowns()
	update_components()
	update_button_text()


func update_components() -> void:
	update_state_components()
	update_elephant()
	update_sea_nodes()
	update_trade_orders()

func update_state_components() -> void:
	var states := _states_by_name()
	for node in find_children("*", "StateComponent", true, false):
		var component := node as StateComponent
		var state_key := component.state_name.strip_edges().to_lower()
		component.stateModel = states.get(state_key)


func update_elephant() -> void:
	var border_spots: Array[Node] = find_children("*", "ElephantBorderSpot", true, false)
	for node in border_spots:
		(node as ElephantBorderSpot).hide_elephant()

	var state := _active_game_state()
	if state == null or state.elephant == null:
		return

	var elephant := state.elephant
	if elephant.placement == EnumTypes.ElephantPlacement.IN_STATE:
		_show_elephant_in_state(border_spots, elephant.current_state)
		return
	if elephant.placement != EnumTypes.ElephantPlacement.ON_BORDER:
		return

	var facing_component := _state_component_for(elephant.facing_state)
	if facing_component == null:
		push_warning("No StateComponent found for the elephant's facing state.")
		return

	for node in border_spots:
		var spot := node as ElephantBorderSpot
		if spot.matches_border(elephant.border_state_a, elephant.border_state_b):
			spot.show_elephant_facing(facing_component.global_position)
			return

	push_warning("No ElephantBorderSpot matches the elephant's current border.")


func _show_elephant_in_state(
	spots: Array[Node],
	location: StateType.StateType
) -> void:
	for node in spots:
		var spot := node as ElephantBorderSpot
		if spot.matches_border(location, location):
			spot.show_elephant()
			return

	push_warning("No ElephantBorderSpot matches the elephant's current state.")


func _state_component_for(location: StateType.StateType) -> StateComponent:
	for node in find_children("*", "StateComponent", true, false):
		var component := node as StateComponent
		if component.stateModel != null and component.stateModel.location == location:
			return component
	return null


func update_sea_nodes() -> void:
	var state := _active_game_state()
	_update_sea_node("SeaNodes/WestSea", state.seaWest if state != null else null)
	_update_sea_node("SeaNodes/SouthSea", state.seaSouth if state != null else null)
	_update_sea_node("SeaNodes/EastSea", state.seaEast if state != null else null)


func _update_sea_node(path: NodePath, sea: SeaModel) -> void:
	var component = get_node_or_null(path)
	if component == null:
		return

	var counts := [0, 0, 0, 0] # Extra, Player, Damaged Player, Company
	if sea != null:
		for ship in sea.ships:
			if ship == null:
				continue
			if ship.shipType == ShipTypes.ShipType.EXTRA:
				counts[0] += 1
			elif ship.shipType == ShipTypes.ShipType.COMPANY:
				counts[3] += 1
			elif ship.isFlipped:
				counts[2] += 1
			else:
				counts[1] += 1

	component.set_counts(counts[0], counts[1], counts[2], counts[3])


func update_trade_orders() -> void:
	for node in find_children("*", "StateComponent", true, false):
		var state_component := node as StateComponent
		var state := state_component.stateModel
		var order_index := 0
		for child in state_component.get_children():
			if child is not TradeOrderComponent:
				continue
			var component := child as TradeOrderComponent
			var has_order := state != null and order_index < state.orders.size()
			component.show()
			component.orderModel = state.orders[order_index] if has_order else null
			order_index += 1


func _states_by_name() -> Dictionary:
	var state := _active_game_state()
	if state == null:
		return {}

	return {
		"bombay": state.bombay,
		"madras": state.madras,
		"hyderabad": state.hyderabad,
		"punjab": state.punjab,
		"bengal": state.bengal,
		"maratha": state.maratha,
		"delhi": state.delhi,
		"mysore": state.mysore,
	}


func _on_button_pressed() -> void:
	_showing_expected = not _showing_expected
	update_components()
	update_button_text()


func _active_game_state() -> GameState:
	return expected_game_state if _showing_expected else game_state


func update_button_text() -> void:
	$SwitchButton.text = "Show Current" if _showing_expected else "Show Expected"


func _on_execute_event_button_pressed() -> void:
	if game_state == null or _events.is_empty():
		push_error("Select an event and provide a GameState first.")
		return

	var main := MAIN.new()
	var result := main.execute_event(
		game_state,
		_events[_selected_event],
		_selected_location
	)
	main.free()

	if result != null:
		_showing_expected = false
		game_state = result
		update_button_text()


func _initialize_dropdowns() -> void:
	var event_popup := event_dropdown.get_popup()
	var location_popup := location_dropdown.get_popup()
	event_popup.clear()
	location_popup.clear()
	_events.clear()

	var known_event_names := {}
	for event in INDIA_EVENTS.events:
		if event == null or known_event_names.has(event.eventName):
			continue
		known_event_names[event.eventName] = true
		_events.append(event)
		event_popup.add_item(event.eventName, _events.size() - 1)

	for location in StateType.StateType.values():
		location_popup.add_item(_location_name(location), location)

	if not event_popup.id_pressed.is_connected(_on_event_selected):
		event_popup.id_pressed.connect(_on_event_selected)
	if not location_popup.id_pressed.is_connected(_on_location_selected):
		location_popup.id_pressed.connect(_on_location_selected)

	if not _events.is_empty():
		_on_event_selected(0)
	_on_location_selected(StateType.StateType.BOMBAY)


func _on_event_selected(id: int) -> void:
	_selected_event = id
	event_dropdown.text = _events[id].eventName


func _on_location_selected(id: int) -> void:
	_selected_location = id as StateType.StateType
	location_dropdown.text = _location_name(id)


func _location_name(location: StateType.StateType) -> String:
	return StateType.name(location)
