extends Rule
class_name InvasionRule

const BATTLE_RESOLVER := preload("res://rules/BattleResolver.gd")

var battle_resolver := BATTLE_RESOLVER.new()

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
	var attackStrength := calculate_attack_strength(game_state, attacker)
	var defenderStates := get_defending_states(game_state, defender)
	var defense_strength := calculate_defense_strength(game_state, defender)
	var attacker_name := StateType.name(attacker.location)
	var defender_name := StateType.name(defender.location)
	ActionManager.add_action(
		ActionFactory.battle_started_action(
			attacker_name, defender_name, attackStrength, defense_strength
		)
	)

	var succeeded := is_invasion_successful(game_state, defender, attackStrength)
	ActionManager.add_action(
		ActionFactory.invasion_result_action(
			attacker_name, defender_name, succeeded
		)
	)
	ActionManager.add_action(
		ActionFactory.battle_result_action(
			attacker_name,
			defender_name,
			attacker_name if succeeded else defender_name
		)
	)

	if succeeded:
		resolve_success(game_state, attacker, defender, defenderStates)
	elif attacker.towerLevel > 0:
		attacker.removeTowerLevel()


func calculate_attack_strength(game_state: GameState, attacker: StateModel) -> int:
	var attacking_states: Array[StateModel] = [attacker]
	if attacker.isPartOfEmpire():
		attacking_states = game_state.getAllStatesOfEmpire(attacker.partOfEmpire)

	var attack_strength := 0
	if EventHelper.activeEvent != null:
		attack_strength = EventHelper.activeEvent.modifier
	for attack_state in attacking_states:
		attack_strength += attack_state.towerLevel
	return attack_strength


func is_invasion_successful(
	game_state: GameState,
	defender: StateModel,
	attack_strength: int
) -> bool:
	var defense_strength := calculate_defense_strength(game_state, defender)
	var winner := battle_resolver.determine_winner(
		attack_strength, defense_strength
	)
	return winner == BATTLE_RESOLVER.Winner.ATTACKER


func calculate_defense_strength(
	game_state: GameState,
	defender: StateModel
) -> int:
	var defense_strength := 0
	for defending_state in get_defending_states(game_state, defender):
		defense_strength += defending_state.towerLevel
	return defense_strength


func get_defending_states(
	game_state: GameState,
	defender: StateModel
) -> Array[StateModel]:
	if defender.isSovereign and defender.isPartOfEmpire():
		return game_state.getAllStatesOfEmpire(defender.partOfEmpire)
	return [defender]


func resolve_success(
	game_state: GameState,
	attacker: StateModel,
	defender: StateModel,
	defender_states: Array[StateModel] = []
) -> void:
	if defender_states.is_empty():
		defender_states = [defender]

	if defender.hasSovereignCapital():
		for defender_state in defender_states:
			defender_state.remove_empire_flag()

	if not attacker.isPartOfEmpire():
		var flag: EnumTypes.Empires = game_state.findFreeEmpireFlags()
		if flag != EnumTypes.Empires.NONE:
			attacker.createNewEmpire(flag)

	defender.become_dominated_by(attacker)
	game_state.mark_successful_invasion_crisis(attacker.location)
	
