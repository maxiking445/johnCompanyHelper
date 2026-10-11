extends Rule
class_name ShuffleEventRule

var elephantRule: Resource = preload("res://rules/ElephantMarchRule.gd")

"""
SHUFFLE EVENT

First perform the Elephant's March. Shuffle this event back into the remaining
draw stack, then shuffle the discard pile and place it facedown on top of the
draw stack. If the draw stack is empty, perform the Elephant's March last.
"""

func execute(game_state: GameState) -> void:
	print("Executing ShuffleEventRule ...")
	var elephantMarchRule: ElephantMarchRule = elephantRule.new()
	# With an empty draw stack, the Elephant marches only after reshuffling.
	var draw_stack_was_empty := EventHelper.draw_pile.is_empty()
	if not draw_stack_was_empty:
		elephantMarchRule.execute(game_state)
	performShuffle()
	if draw_stack_was_empty:
		elephantMarchRule.execute(game_state)

	
		
func performShuffle():
	var activeEvent: IndiaEvent = EventHelper.activeEvent
	EventHelper.removeEvent(activeEvent)
	EventHelper.addEventToDrawPile(activeEvent)
	EventHelper.shuffleDrawCards()
	EventHelper.shuffleDiscardCards()
	EventHelper.shuffleDiscardIntoDrawPile()
	print("Shuffled Event Deck.. DiscardPile is now on Top")
