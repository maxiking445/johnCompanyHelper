@tool
extends Control


@export var data_entries: Dictionary = {}:
	set(value):
		data_entries = value
		if is_node_ready():
			update_entries()

@onready var vbox: VBoxContainer = $PanelContainer/VBoxContainer
@onready var template: HBoxContainer = $PanelContainer/VBoxContainer/DataEntry0


func _ready() -> void:
	update_entries()


func update_entries() -> void:
	for child in vbox.get_children():
		if child != template:
			child.queue_free()

	template.hide()
	for title in data_entries:
		var row := template.duplicate() as HBoxContainer
		row.get_node("DataEntryTitle").text = str(title)
		row.get_node("DataEntryValue").text = str(data_entries[title])
		row.show()
		vbox.add_child(row)
