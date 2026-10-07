extends Control

const DEFAULT_GAME_STATE := preload("res://resources/gameState/GameState1710.tres")
const MENU_SCENE := "res://scenes/menue.tscn"

var storm_rule := StormRule.new()
var gameState: GameState
var launch_mode: int = -1
@onready var navigation: HBoxContainer = $Navigation
@onready var transition_dimmer: ColorRect = $EventSummary/TransitionDimmer
var transition_tween: Tween
var is_last_event_shown: bool = false


func _ready() -> void:
	navigation.hide()
	get_viewport().size_changed.connect(_update_navigation_layout)
	_update_navigation_layout()
	if launch_mode == 0:
		call_deferred("start_normal_game")
	elif launch_mode == 1:
		call_deferred("continue_game")


func _update_navigation_layout() -> void:
	var viewport_size := get_viewport_rect().size
	var portrait := viewport_size.y >= viewport_size.x
	var next_width := clampf(viewport_size.x * (0.14 if portrait else 0.12), 240.0, 320.0)
	var finish_width := clampf(viewport_size.x * (0.28 if portrait else 0.2), 360.0, 460.0)
	var button_height := 96.0 if portrait else 88.0
	%NextButton.custom_minimum_size = Vector2(next_width, button_height)
	%FinishButton.custom_minimum_size = Vector2(finish_width, button_height)
	for button in navigation.get_children():
		if button is Button:
			button.add_theme_font_size_override("font_size", 36)
	var navigation_width := next_width + finish_width + 14.0
	navigation.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	navigation.size = Vector2(navigation_width, button_height)
	navigation.position = Vector2((viewport_size.x - navigation_width) * 0.5 if portrait else viewport_size.x - navigation_width - 28.0, viewport_size.y - button_height - 24.0)


func start_normal_game() -> GameState:
	ActionManager.clear()
	_set_game_state(
		gameState if gameState != null else DEFAULT_GAME_STATE.duplicate(true)
	)
	EventHelper.initEventDeck(true)
	EventHelper.resetPlayedEvents()
	start_game_from_state(gameState)
	_initialize_ui()
	return gameState


func continue_game() -> GameState:
	EventHelper.resetPlayedEvents()
	if EventHelper.draw_pile.is_empty():
		EventHelper.initEventDeck(true)
	start_game_from_state(gameState)
	_initialize_ui()
	return gameState


func start_game_from_state(start_game_state: GameState) -> GameState:
	if start_game_state == null:
		push_error("Cannot start a round without a GameState.")
		return null
	_set_game_state(start_game_state)
	RollHelper.clearQueuedResults()
	storm_rule.execute(gameState)
	_resolve_events(gameState, gameState.eventsToDraw)
	return gameState


func start_test_game(
	start_game_state: GameState,
	event_deck: Array[IndiaEvent],
	events_to_resolve: int,
	d6_results: Array[int] = [],
	storm_dice_results: Array[StormDice.Face] = []
) -> GameState:
	if start_game_state == null:
		push_error("A deterministic game needs a start GameState.")
		return null
	if events_to_resolve < 0 or events_to_resolve > event_deck.size():
		push_error("The deterministic event count must fit the supplied deck.")
		return null

	ActionManager.clear()
	_set_game_state(start_game_state.duplicate(true))
	EventHelper.draw_pile = event_deck.duplicate()
	EventHelper.discard_pile.clear()
	EventHelper.activeEvent = null
	RollHelper.clearQueuedResults()
	RollHelper.d6_results = d6_results.duplicate()
	RollHelper.storm_dice_results = storm_dice_results.duplicate()
	gameState.eventsToDraw = events_to_resolve
	_resolve_events(gameState, events_to_resolve)
	return gameState


func execute_event(
	start_game_state: GameState,
	event: IndiaEvent,
	location: StateType.StateType
) -> GameState:
	if start_game_state == null or event == null or event.rule == null:
		push_error("Executing an event needs a GameState and a valid event.")
		return null

	ActionManager.clear()
	_set_game_state(start_game_state.duplicate(true))
	var location_event := IndiaEvent.new()
	location_event.eventLocation = location
	EventHelper.draw_pile = [location_event]
	EventHelper.discard_pile = [event]
	EventHelper.activeEvent = event
	ActionManager.add_action(
		ActionFactory.draw_event_action(event.eventName, StateType.name(location))
	)
	event.rule.execute(gameState)
	EventHelper.eventHandled()
	return gameState


func _set_game_state(new_game_state: GameState) -> void:
	gameState = new_game_state


func _resolve_events(target_game_state: GameState, event_count: int) -> void:
	print("Event count: ", event_count)
	for _event_index in range(event_count):
		if EventHelper.draw_pile.is_empty():
			push_error("The event deck is empty before all events were resolved.")
			return

		var event := EventHelper.drawEvent()
		ActionManager.add_action(
			ActionFactory.draw_event_action(
				event.eventName,
				StateType.name(EventHelper.getTopDeckEventLocation())
			)
		)
		event.rule.execute(target_game_state)


func _initialize_ui() -> void:
	%FinishButton.disabled = true
	%NextButton.disabled = false
	%EventSummary.removeLog()
	var first_event_value: PlayedEvent = EventHelper.getPlayedEventAt(0)
	var current_event: IndiaEvent = first_event_value.currentEvent
	var top_deck_event: IndiaEvent = first_event_value.topdeckEvent
	%EventSummary.initialize(0, top_deck_event, current_event, gameState.completedRounds + 1)
	%EventSummary.show()


func _on_next_button_pressed() -> void:
	if %EventSummary.is_card_animating():
		return
	%EventSummary.next()


func _on_finish_button_pressed() -> void:
	if %EventSummary.is_card_animating():
		return
	gameState.completedRounds += 1
	var save_error: Error = get_node("/root/SaveGameManager").save_current(gameState)
	if save_error != OK:
		gameState.completedRounds -= 1
		push_error("The current GameState could not be saved.")
		return
	get_tree().change_scene_to_file(MENU_SCENE)


func _on_event_summary_last_event_shown() -> void:
	is_last_event_shown = true
	%FinishButton.disabled = false
	%NextButton.disabled = true


func _on_event_summary_presentation_changed(revealed: bool) -> void:
	if transition_tween != null and transition_tween.is_valid():
		transition_tween.kill()
	transition_tween = create_tween()
	if revealed:
		navigation.show()
		%NextButton.disabled = is_last_event_shown
		transition_tween.tween_property(transition_dimmer, "modulate:a", 0.0, 0.35)
	else:
		%NextButton.disabled = true
		transition_dimmer.show()
		transition_tween.tween_property(transition_dimmer, "modulate:a", 0.72, 0.4)
