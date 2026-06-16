extends Node

func rollD6() -> int:
	return randi_range(1, 6)

func rollStormDice() -> StormDice.Face:
	var result: StormDice.Face = randi_range(0, 5)
	print("RES: ", result)
	return result
