extends Control

const EVENT_LOG_ENTRY_SCENE := preload("res://scenes/component/EventLogEntry.tscn")

@export var actionList: Array[Action]
@export var entry_delay: float = 0.15
@export var topDeckEvent: IndiaEvent 
@export var currentEvent: IndiaEvent 
@onready var eventLogList: VBoxContainer = $EventLogList

func _ready() -> void:
	$EventShowComponent.topDeckEvent = topDeckEvent
	$EventShowComponent.currentDeckEvent = currentEvent

func populate_event_log() -> void:
	for action in actionList:
		var event_log_entry := EVENT_LOG_ENTRY_SCENE.instantiate()
		event_log_entry.event = action
		eventLogList.add_child(event_log_entry)

		if entry_delay > 0.0:
			await get_tree().create_timer(entry_delay).timeout
