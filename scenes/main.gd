extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Start!")
	EventHelper.initEvent()
	print(EventHelper.removeEvent(EventHelper.getRandomEvent()))
	print(EventHelper.getEvents().size())
	print(EventHelper.removeEvent(EventHelper.getRandomEvent()))
	print(EventHelper.getEvents().size())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
