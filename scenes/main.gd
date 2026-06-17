extends Node2D

var stormRule: Resource = preload("res://rules/StormRule.gd")
var windfallRule: Resource = preload("res://rules/events/WindfallEventRule.gd")
var suffleRule: Resource = preload("res://rules/events/ShuffleEventRule.gd")
var gameState: GameState = preload("res://resources/gameState/GameState.tres")


func _ready() -> void:
	#test()
	EventHelper.initEventDeck(false)
	var stormRule: StormRule = stormRule.new()
	stormRule.execute(gameState)
	
	for i in range(gameState.eventsToDraw):
		print("Draw Event Card.")
		var event: IndiaEvent = EventHelper.drawEvent()
		print(event.eventName)
		print(event.rule)
		event.rule.execute(gameState)

func test() -> void:
	print("Start!")
	
	print(EventHelper.drawEvent())
	print(EventHelper.draw_pile.size())
	print(EventHelper.drawEvent())
	print(EventHelper.draw_pile.size())
	var stormRule: StormRule = stormRule.new()
	stormRule.execute(gameState)
	
	var windfallRule: WindfallEventRule = windfallRule.new()
	windfallRule.execute(gameState)
	
	var shuffleEventRule: ShuffleEventRule = suffleRule.new()
	shuffleEventRule.execute(gameState)
