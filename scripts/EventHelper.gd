extends Node

const IndiaEventsDatabase: IndiaEvents = preload("res://resources/events/IndiaEvents.tres")

var events: Array[IndiaEvent] = []

func initEvent() -> void:
	events = IndiaEventsDatabase.events.duplicate()


func getEvents() -> Array[IndiaEvent]:
	return events 

func removeEvent(event: IndiaEvent):
	events.erase(event)
	
func getRandomEvent() -> IndiaEvent:
	return events.pick_random()
