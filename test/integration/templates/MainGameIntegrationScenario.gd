extends Resource
class_name MainGameIntegrationScenario

@export var scenario_name: String
@export var start_game_state: GameState
@export var expected_game_state: GameState
# Events that are actually drawn and resolved, in order.
@export var event_deck: Array[IndiaEvent] = []
# The next facedown tile; its back determines the location after the last draw.
@export var location_event: IndiaEvent
@export var d6_results: Array[int] = []
@export var storm_dice_results: Array[StormDice.Face] = []
