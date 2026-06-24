extends Node

var d6_results: Array[int] = []
var storm_dice_results: Array[StormDice.Face] = []


func rollD6() -> int:
	if !d6_results.is_empty():
		return d6_results.pop_front()

	return randi_range(1, 6)

func rollStormDice() -> StormDice.Face:
	if !storm_dice_results.is_empty():
		return storm_dice_results.pop_front()

	var result: StormDice.Face = randi_range(0, 5)
	print("RES: ", result)
	return result


func clearQueuedResults() -> void:
	d6_results.clear()
	storm_dice_results.clear()
