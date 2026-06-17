@abstract
extends Resource
class_name Rule

@export var ruleName: String

@abstract
func execute(game_state: GameState) -> void
