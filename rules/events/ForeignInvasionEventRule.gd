extends Rule
class_name ForeignInvasionEventRule

"""
FOREIGN INVASION EVENT

Roll the storm die and resolve an Invasion Crisis or an Attack against the
Company in each region linked to a storm: Bombay for West Indian, Madras for
South Indian, and Bengal for East Indian. Resolve all three when all storms are
rolled. If no storm is rolled, use the region on top of the draw stack.

For each affected region, roll a die and use the result as the Invasion's base
strength. A successful invasion closes its orders, removes its empire flag or
Company control, and sets its new strength to half the invasion strength,
rounded down.

Elephant Redirect.
If the Elephant was fully within a Companycontrolled region that was invaded, perform an Elephant's March
using• for the shape. (Otherwise this event does not move the Elephant.)
"""

func execute(game_state: GameState) -> void:
	print("ForeignInvasionEventRule is not yet implemented")
