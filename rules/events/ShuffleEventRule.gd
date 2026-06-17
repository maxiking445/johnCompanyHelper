extends Rule
class_name ShuffleEventRule

var elephantRule: Resource = preload("res://rules/ElephantMarchRule.gd")

func execute(game_state: GameState) -> void:
	print("Executing ShuffleEventRule ...")
	var elephantMarchRule: ElephantMarchRule = elephantRule.new()
	elephantMarchRule.execute(game_state)
	
	performShuffle()

	
		
func performShuffle():
	var activeEvent: IndiaEvent = EventHelper.activeEvent
	EventHelper.removeEvent(activeEvent)
	EventHelper.addEventToDrawPile(activeEvent)
	EventHelper.shuffleDrawCards()
	EventHelper.shuffleDiscardCards()
	EventHelper.shuffleDiscardIntoDrawPile()
	print("Shuffled Event Deck.. DiscardPile is now on Top")
