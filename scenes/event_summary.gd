extends Control

const EVENT_LOG_ENTRY_SCENE := preload("res://scenes/component/EventLogEntry.tscn")

@export var actionList: Array[Action]
@export var entry_delay: float = 0.5
@export var topDeckEvent: IndiaEvent 
@export var currentEvent: IndiaEvent 
@export var index: int 
@onready var eventLogList: VBoxContainer = %EventLogList
@onready var event_counter: Label = %EventCounter

signal lastEventShown

func _ready() -> void:
	pass


func initialize(
	index: int,
	new_top_deck_event: IndiaEvent,
	new_current_event: IndiaEvent
) -> void:
	self.index = index
	topDeckEvent = new_top_deck_event
	currentEvent = new_current_event
	actionList = ActionManager.get_actions_by_event_id(currentEvent.eventId)
	$EventShowComponent.initialize_events(topDeckEvent, currentEvent)
	_update_event_counter()
	if index + 1 == EventHelper.getPlayedEvents().size():
		lastEventShown.emit()
	

func populate_event_log() -> void:
	for child in eventLogList.get_children():
		child.queue_free()

	for action in actionList:
		var event_log_entry := EVENT_LOG_ENTRY_SCENE.instantiate()
		event_log_entry.initialize(action)
		eventLogList.add_child(event_log_entry)

		if entry_delay > 0.0:
			await get_tree().create_timer(entry_delay).timeout


func _on_event_show_component_flip_finished() -> void:
	populate_event_log()


func next() -> void:
	var event_count := EventHelper.getPlayedEvents().size()
	var next_index := index + 1
	if next_index >= event_count:
		print("NO MORE EVENTS!")
		return

	var firstEventValue = EventHelper.getPlayedEventAt(next_index)
	var current_event: IndiaEvent = firstEventValue.currentEvent
	var top_deck_event: IndiaEvent = firstEventValue.topdeckEvent
	topDeckEvent = top_deck_event
	currentEvent = current_event
	actionList = ActionManager.get_actions_by_event_id(currentEvent.eventId)
	removeLog()
	index = next_index
	_update_event_counter()
	$EventShowComponent.initialize_events(topDeckEvent, currentEvent, true)
	if index + 1 == event_count:
		lastEventShown.emit()


func _update_event_counter() -> void:
	var event_count := EventHelper.getPlayedEvents().size()
	event_counter.text = "EVENT %d / %d" % [index + 1, event_count]
	
func removeLog():
	for child in eventLogList.get_children():
		child.queue_free()	
