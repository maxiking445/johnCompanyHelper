extends Node

const IndiaEventsDatabase: IndiaEvents = preload("res://resources/events/IndiaEvents.tres")


var draw_pile: Array[IndiaEvent] = []
var discard_pile: Array[IndiaEvent] = []
var activeEvent: IndiaEvent

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
	return event

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
