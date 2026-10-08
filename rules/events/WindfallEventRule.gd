extends Rule
class_name WindfallEventRule



"""
WINDFALL EVENT

Each player takes £1 from the bank for each writer they have on an order in
the region pictured on top of the draw stack and in every adjacent region.
"""

func execute(game_state: GameState) -> void:
	var target_region := StateType.name(EventHelper.getTopDeckEventLocation())
	ActionManager.add_action(ActionFactory.windfall_pay_writers_action(target_region))
