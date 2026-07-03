class_name ElephantRedirectRule
extends Rule

const CIRCLE_BORDER_INDEX := 0

var elephant_march_rule := ElephantMarchRule.new()

"""
ELEPHANT REDIRECT

If the Elephant is wholly inside a Company-controlled region when that region
is lost, redirect it by performing the required Elephant's March. A Company
attack elsewhere does not redirect an Elephant standing on a border.
"""

func execute(game_state: GameState) -> void:
	print("Executing ElephantRedirectRule ...")
	if game_state == null:
		push_error("ElephantRedirectRule needs a game state.")
		return
	if game_state.elephant == null:
		return
	if not game_state.elephant.is_inside_state():
		return

	var location: StateType.StateType = game_state.elephant.current_state
	var state: StateModel = game_state.findStateByLocation(location)
	if state == null or not state.hasRebelled:
		return

	state.hasRebelled = false
	elephant_march_rule.execute(game_state)


func execute_with_circle_shape(game_state: GameState) -> void:
	if EventHelper.draw_pile.is_empty():
		execute(game_state)
		return

	var top_event: IndiaEvent = EventHelper.draw_pile.front()
	var original_border_index: int = top_event.elephantBorderIndex
	top_event.elephantBorderIndex = CIRCLE_BORDER_INDEX
	execute(game_state)
	top_event.elephantBorderIndex = original_border_index
	
