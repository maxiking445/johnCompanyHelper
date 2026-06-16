extends Node2D

var stormRule: Resource = preload("res://rules/StormRule.gd")
var gameState: Resource = preload("res://resources/gameState/GameState.tres")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Start!")
	EventHelper.initEvent()
	print(EventHelper.removeEvent(EventHelper.getRandomEvent()))
	print(EventHelper.getEvents().size())
	print(EventHelper.removeEvent(EventHelper.getRandomEvent()))
	print(EventHelper.getEvents().size())
	var stormRule: StormRule = stormRule.new()
	stormRule.execute(gameState)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
