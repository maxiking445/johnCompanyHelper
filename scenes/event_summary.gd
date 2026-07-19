extends Control

const EVENT_LOG_ENTRY_SCENE := preload("res://scenes/component/EventLogEntry.tscn")

@export var actionList: Array[Action]
@export var entry_delay: float = 0.5
@export var topDeckEvent: IndiaEvent 
@export var currentEvent: IndiaEvent 
@onready var eventLogList: VBoxContainer = $EventLogList

func _ready() -> void:
	pass


func initialize(
	new_action_list: Array[Action],
	new_top_deck_event: IndiaEvent,
	new_current_event: IndiaEvent
) -> void:
	actionList = new_action_list
	topDeckEvent = new_top_deck_event
	currentEvent = new_current_event
	$EventShowComponent.initialize_events(topDeckEvent, currentEvent)
	

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
