extends Node

func rollD6() -> int:
	return randi_range(1, 6)

func rollStormDice() -> StormDice:
	return StormDice.Face.get(randi_range(0, 5))
