extends Rule
class_name AttackAgainstCompanyRule

const BATTLE_RESOLVER := preload("res://rules/BattleResolver.gd")

var loose_region_rule := LooseRegionRule.new()
var invasion_rule := InvasionRule.new()
var battle_resolver := BATTLE_RESOLVER.new()

"""
  ATTACKS AGAINST THE COMPANY

  Both Invasions and Rebellions against Company-controlled regions are
  resolved in the same way.

  Whenever the Company is attacked by any type of Crisis, resolve the
  primary Crisis first. Then resolve an additional Rebellion Crisis in
  each other region containing unrest cubes.

  Order of Resolution:
  - Always resolve the primary Crisis first.
  - Then resolve attacks by Presidency, starting with the Commander of
    the Army of Bombay and proceeding downwards.
  - Each Commander chooses the order in which regions associated with
    their Presidency are resolved.

  Vacant Commander:
  - If the Commander position is vacant, Military Affairs acts in its
    place and makes decisions such as which pieces to exhaust.
  - If Military Affairs is also vacant, the Chairman makes these decisions.
  - A player acting in place of a Commander neither gains nor loses trophies.

  Attack Strength:
  - For the primary Crisis, calculate the base strength according to its
    type: Invasion or Rebellion.
  - Add one strength for every unrest cube in the attacked region.
  - For each additional Rebellion, the attack strength equals the number
    of unrest cubes in that region.

  Mounting Defense:
  - The Commander associated with the attacked region must exhaust Army
    pieces equal to the Crisis strength, or as many pieces as possible.
  - If the number of newly exhausted pieces is lower than the Crisis
    strength, the Crisis succeeds. Perform the Region Loss procedure.
  - If the Crisis fails, remove all unrest cubes from the attacked region.
    The associated Commander gains one trophy token.

  Failed and Successful Invasions:
  - If the primary Crisis was an Invasion that failed, remove one tower
    level from the attacking region, if possible.
  - If the Invasion succeeded, follow the rules for empire creation and
    growth described on the previous page.
  """
func execute(game_state: GameState) -> void:
	print("Executing AttackAgainstCompanyRule ...")
	if game_state == null:
		push_error("AttackAgainstCompanyRule needs a game state.")
		return

	var primary_state := game_state.findStateByLocation(
		EventHelper.getTopDeckEventLocation()
	)
	execute_for_state(game_state, primary_state)


func execute_for_state(
	game_state: GameState,
	primary_state: StateModel,
	base_strength = null,
	invasion_attacker: StateModel = null,
	attacker_name_override: String = ""
) -> bool:
	if game_state == null or primary_state == null:
		push_error("AttackAgainstCompanyRule needs a game state and primary state.")
		return false

	loose_region_rule.reset_lost_regions_this_round()
	var primary_base_strength: int = (
		get_event_modifier() if base_strength == null else base_strength
	)
	var primary_attacker_name := (
		attacker_name_override
		if not attacker_name_override.is_empty()
		else StateType.name(invasion_attacker.location)
		if invasion_attacker != null
		else "Crisis"
	)
	var primary_attack_succeeded := resolve_attack(
		game_state, primary_state, primary_base_strength, primary_attacker_name
	)

	if invasion_attacker != null:
		if primary_attack_succeeded:
			invasion_rule.resolve_success(
				game_state, invasion_attacker, primary_state
			)
		elif invasion_attacker.towerLevel > 0:
			invasion_attacker.removeTowerLevel()

	var states_with_unrest := game_state.findAllStatesWithUnrest()
	states_with_unrest.sort_custom(
		func(left: StateModel, right: StateModel) -> bool:
			if left.presidency == right.presidency:
				return left.location < right.location
			return left.presidency < right.presidency
	)
	for state in states_with_unrest:
		if state != primary_state and state.isCompanyControlled:
			resolve_attack(game_state, state, 0, "Local unrest")
	return primary_attack_succeeded


# Keep the original entry point for callers that already use it.
func execute_state(game_state: GameState, primary_state: StateModel) -> void:
	execute_for_state(game_state, primary_state)


func resolve_attack(
	game_state: GameState,
	state: StateModel,
	base_strength: int,
	attacker_name: String = "Crisis"
) -> bool:
	var attack_strength := maxi(0, base_strength + state.unrest_size)
	var presidency := game_state.get_presidency(state)
	if presidency == null or presidency.army == null:
		push_error("Company-controlled region %s needs an associated Presidency and Army." % StateType.name(state.location))
		return false
	var available_strength := presidency.army.available_strength()
	var defender_name := "Company in %s" % StateType.name(state.location)
	ActionManager.add_action(
		ActionFactory.battle_started_action(
			attacker_name, defender_name, attack_strength, available_strength
		)
	)
	var exhausted_strength := presidency.army.exhaust_for_defense(
		attack_strength, game_state.get_presidency_name(state)
	)

	var winner := battle_resolver.determine_winner(attack_strength, exhausted_strength)
	ActionManager.add_action(
		ActionFactory.battle_result_action(
			attacker_name,
			defender_name,
			attacker_name
			if winner == BATTLE_RESOLVER.Winner.ATTACKER
			else defender_name
		)
	)
	if winner == BATTLE_RESOLVER.Winner.ATTACKER:
		loose_region_rule.execute_for_state(game_state, state)
		return true
	else:
		state.resetUnrest()
		ActionManager.add_action(
			ActionFactory.add_trophy_action(StateType.name(state.location))
		)
		return false


func get_event_modifier() -> int:
	if EventHelper.activeEvent == null:
		return 0
	return EventHelper.activeEvent.modifier
