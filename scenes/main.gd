extends Control

const DEFAULT_GAME_STATE := preload("res://resources/gameState/GameState1710.tres")
const MENU_SCENE := "res://scenes/menue.tscn"

var storm_rule := StormRule.new()
var gameState: GameState
var launch_mode: int = -1


func _ready() -> void:
	if launch_mode == 0:
		call_deferred("start_normal_game")
	elif launch_mode == 1:
		call_deferred("continue_game")


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
	%EventSummary.initialize(0, top_deck_event, current_event)
	%EventSummary.show()


func _on_next_button_pressed() -> void:
	%EventSummary.next()


func _on_finish_button_pressed() -> void:
	var save_error: Error = get_node("/root/SaveGameManager").save_current(gameState)
	if save_error != OK:
		push_error("The current GameState could not be saved.")
		return
	get_tree().change_scene_to_file(MENU_SCENE)


func _on_event_summary_last_event_shown() -> void:
	%FinishButton.disabled = false
	%NextButton.disabled = true
