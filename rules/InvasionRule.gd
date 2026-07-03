extends Rule
class_name InvasionRule
"""
If the attacker is a sovereign region, resolve an Invasion. Determine
whether the attacker's strength (including the strength of any other regions
in its empire) plus the modifier listed on the event tile is greater than
the defender's strength (including the strength of any other regions in its
empire). If so, the Invasion is successful; otherwise, the Invasion fails.

If the Invasion succeeded, remove any flag on the defending region's
dome and place a flag matching the attacker.
	* Shattered Empire. If the defending region was a capital, any
	flags matching its empire are returned to the supply.
	* New Empire. If the attacker was successful and does not have a
	flag, place any flag with a star still in the supply on their dome.
	if none remain, a new empire cannot be formed and no flag is
	added to the attacker or defender.

If the Invasion failed, remove one tower level from the attacker.
"""
func execute(game_state: GameState) -> void:
	print("Executing InvasionRule ...")
	printerr("Not implemented!")

func execute_detail(game_state: GameState, attacker: StateModel, defender: StateModel)-> void:
	var attackingStates: Array[StateModel]	= game_state.getAllStatesOfEmpire(attacker.partOfEmpire)
	var attackStrength: int = EventHelper.activeEvent.modifier
	for attackState in attackingStates:
		attackStrength = attackStrength + attackState.towerLevel
	
	var defenderStates: Array[StateModel] = []
	if defender.isSovereign:
		defenderStates = game_state.getAllStatesOfEmpire(defender.partOfEmpire)
	else:
		defenderStates.append(defender)

	var defenderStrength: int = 0
	for defenderState in defenderStates:
		defenderStrength = defenderStrength + defenderState.towerLevel
		
	if defenderStrength >= attackStrength:
		attacker.removeTowerLevel()
	else:
		defender.partOfEmpire = attacker.partOfEmpire
		if defender.hasSovereignCapital():
			for defenderState in defenderStates:
				defenderState.partOfEmpire = EnumTypes.Empires.NONE
		
		if !attacker.isPartOfEmpire():
			var flag: EnumTypes.Empires = game_state.findFreeEmpireFlags()
			if flag != EnumTypes.Empires.NONE:
				attacker.createNewEmpire(flag)
	
