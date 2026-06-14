@tool
extends Container

@export var status_name: String 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_ui()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_ui() -> void:
	$MarginContainer/Label.text = status_name
