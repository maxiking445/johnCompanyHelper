extends Node

const IndiaEventsDatabase: IndiaEvents = preload("res://resources/events/IndiaEvents.tres")


var draw_pile: Array[IndiaEvent] = []
var discard_pile: Array[IndiaEvent] = []
var activeEvent: IndiaEvent
var playedEvents: Dictionary[int, PlayedEvent] = {}

func initEventDeck(shuffle_deck: bool = true) -> void:
	draw_pile = IndiaEventsDatabase.events.duplicate()
	discard_pile.clear()

	if shuffle_deck:
		shuffleDrawCards()

func removeEvent(event: IndiaEvent):
	discard_pile.erase(event)

func addEventToDrawPile(event: IndiaEvent):
	draw_pile.append(event)

	
func drawEvent() -> IndiaEvent:
	if draw_pile.is_empty():
		shuffleAllCards()

	var event: IndiaEvent = draw_pile.pop_front()
	discard_pile.append(event)
	activeEvent = event
	addPlayedEvent()
	return event

func addPlayedEvent():
	var playedEvent = PlayedEvent.new()
	playedEvent.topdeckEvent = getTopDeckEvent()
	playedEvent.currentEvent = activeEvent
	playedEvent.remainingDeck.assign(draw_pile)
	playedEvents[activeEvent.eventId] = playedEvent

func getPlayedEvents() -> Dictionary[int, PlayedEvent]: 
	return playedEvents

func getPlayedEventAt(index: int)-> PlayedEvent:
	var event = EventHelper.getPlayedEvents().keys()[index]
	var value: PlayedEvent = EventHelper.getPlayedEvents()[event]
	return value

func resetPlayedEvents():
	playedEvents = {}

func eventHandled():
	activeEvent = null

func shuffleDiscardIntoDrawPile() -> void:
	if discard_pile.is_empty():
		return
		
	discard_pile.shuffle()
	draw_pile.append_array(discard_pile)
	discard_pile.clear()
	
func shuffleDiscardCards() -> void:
	discard_pile.shuffle()	

func shuffleDrawCards() -> void:
	draw_pile.shuffle()

func shuffleAllCards() -> void:
	draw_pile.append_array(discard_pile)
	discard_pile.clear()
	draw_pile.shuffle()

func getTopDeckEventLocation() -> StateType.StateType:
	if draw_pile.is_empty():
		print("EventDeck is empty!")

	return draw_pile.front().eventLocation


func getTopDeckEvent() -> IndiaEvent:
	if draw_pile.is_empty():
		print("EventDeck is empty!")
	return draw_pile.front()


func getEventByEventId(id: int ) -> IndiaEvent:
	for event: IndiaEvent in IndiaEventsDatabase.events:
		if event.eventId == id:
			return event
	printerr("Could not find Event with EventID: ", id)			
	return null
