class_name StormDice
enum Face {
	FOUR_A,
	FOUR_B,
	SOUTH_3, 
	EAST_2,
	WEST_2,
	STORMS_ALL
}

static func name(state: StormDice.Face) -> String:
	return StormDice.Face.keys()[state]
