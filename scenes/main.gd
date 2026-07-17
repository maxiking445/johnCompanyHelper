extends Control

const DEFAULT_GAME_STATE := preload("res://resources/gameState/GameState1710.tres")

var storm_rule := StormRule.new()
var gameState: GameState



func start_normal_game() -> GameState:
	return start_game_from_state(DEFAULT_GAME_STATE)


func start_game_from_state(start_game_state: GameState) -> GameState:
	_set_game_state(start_game_state.duplicate(true))
	EventHelper.initEventDeck(false)
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

	_set_game_state(start_game_state.duplicate(true))
	var location_event := IndiaEvent.new()
	location_event.eventLocation = location
	EventHelper.draw_pile = [location_event]
	EventHelper.discard_pile = [event]
	EventHelper.activeEvent = event
	event.rule.execute(gameState)
	EventHelper.eventHandled()
	return gameState  


func _set_game_state(new_game_state: GameState) -> void:
	gameState = new_game_state
	var resource_loader := get_node_or_null("ResourceLoader")
	if resource_loader != null:
		resource_loader.game_state = gameState


func _resolve_events(target_game_state: GameState, event_count: int) -> void:
	for event_index in range(event_count):
		if EventHelper.draw_pile.is_empty():
			push_error("The event deck is empty before all events were resolved.")
			return

		var event := EventHelper.drawEvent()
		if event == null or event.rule == null:
			push_error("Every drawn event needs an executable rule.")
			return
		event.rule.execute(target_game_state)





func _on_resource_loader_download_gamestate(_downloaded_game_state: GameState) -> void:
	pass


func _on_resource_loader_upload_gamestate(loaded_game_state: GameState) -> void:
	if loaded_game_state == null:
		push_error("Cannot restart the game without a loaded GameState.")
		return
	start_game_from_state(loaded_game_state)


func _on_start_button_pressed() -> void:
	start_normal_game()
