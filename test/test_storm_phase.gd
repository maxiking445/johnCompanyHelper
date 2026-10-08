extends GutTest

const PHASE := preload("res://scenes/StormPhase.tscn")
const MAIN := preload("res://scenes/main.tscn")
const STATE := preload("res://resources/gameState/GameState1710.tres")


func after_each() -> void:
	RollHelper.clearQueuedResults()
	ActionManager.clear()
	for played_event in EventHelper.playedEvents:
		played_event.free()
	EventHelper.resetPlayedEvents()
	EventHelper.activeEvent = null


func test_each_face_reveals_once_and_reports_event_count() -> void:
	var counts := [4, 4, 3, 2, 2, 1]
	for face_index in counts.size():
		var phase := PHASE.instantiate()
		add_child_autofree(phase)
		phase.flip_duration = 0.0
		var state := STATE.duplicate(true)
		state.seaWest.ships.clear()
		state.seaEast.ships.clear()
		state.seaSouth.ships.clear()
		phase.initialize(state)
		assert_false(phase.result.visible)
		assert_false(phase.continue_button.visible)
		RollHelper.storm_dice_results.assign([face_index, StormDice.Face.FOUR_A])
		await phase._reveal()
		assert_eq(state.eventsToDraw, counts[face_index])
		assert_eq(phase.rule.last_result, face_index)
		assert_true(phase.result.visible)
		assert_true(phase.continue_button.visible)
		await phase._reveal()
		assert_eq(RollHelper.storm_dice_results.size(), 1, "Repeated taps must not reroll")
		phase.hide()


func test_new_game_waits_for_storm_before_drawing_events() -> void:
	var main := MAIN.instantiate()
	add_child_autofree(main)
	main.start_normal_game()
	# Keep this transition check independent of randomly drawn event rules.
	var windfall: IndiaEvent = load("res://resources/events/windfall/Windfall_MAD.tres")
	EventHelper.draw_pile.clear()
	for index in range(5):
		var event := windfall.duplicate(true)
		event.eventId = 100 + index
		EventHelper.draw_pile.append(event)
	var phase = main.get_node("StormPhase")
	assert_true(phase.visible)
	assert_false(main.get_node("EventSummary").visible)
	assert_eq(EventHelper.playedEvents.size(), 0)
	phase.flip_duration = 0.0
	RollHelper.storm_dice_results.assign([StormDice.Face.FOUR_A])
	await phase._reveal()
	assert_eq(EventHelper.playedEvents.size(), 0)
	phase._continue()
	assert_false(phase.visible)
	assert_true(main.get_node("EventSummary").visible)
	assert_eq(EventHelper.playedEvents.size(), 4)
	phase._continue()
	assert_eq(EventHelper.playedEvents.size(), 4, "Continue must not draw twice")


func test_continue_keeps_round_and_deck_until_storm_is_acknowledged() -> void:
	var main := MAIN.instantiate()
	add_child_autofree(main)
	main.gameState = STATE.duplicate(true)
	main.gameState.completedRounds = 2
	var windfall: IndiaEvent = load("res://resources/events/windfall/Windfall_MAD.tres")
	EventHelper.draw_pile.clear()
	for index in range(5):
		var event := windfall.duplicate(true)
		event.eventId = 200 + index
		EventHelper.draw_pile.append(event)
	main.continue_game()
	var phase = main.get_node("StormPhase")
	assert_eq(main.gameState.completedRounds, 2)
	assert_eq(EventHelper.draw_pile.size(), 5)
	assert_eq(EventHelper.playedEvents.size(), 0)
	phase.flip_duration = 0.0
	RollHelper.storm_dice_results.assign([StormDice.Face.EAST_2])
	await phase._reveal()
	assert_eq(EventHelper.draw_pile.size(), 5)
	phase._continue()
	assert_eq(EventHelper.playedEvents.size(), 2)
	assert_eq(EventHelper.playedEvents[0].currentEvent.eventId, 200)
	assert_eq(EventHelper.draw_pile.size(), 3)
	assert_eq(main.gameState.completedRounds, 2)
