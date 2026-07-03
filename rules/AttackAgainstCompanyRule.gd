extends Rule
class_name AttackAgainstCompanyRule

var loose_region_rule := LooseRegionRule.new()
var elephant_redirect_rule := ElephantRedirectRule.new()

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


func execute_for_state(game_state: GameState, primary_state: StateModel) -> void:
	if game_state == null or primary_state == null:
		push_error("AttackAgainstCompanyRule needs a game state and primary state.")
		return

	loose_region_rule.reset_lost_regions_this_round()
	resolve_attack(game_state, primary_state, get_event_modifier())


	var states_with_unrest := game_state.findAllStatesWithUnrest()
	for state in states_with_unrest:
		if state != primary_state:
			resolve_attack(game_state, state, 0)


# Keep the original entry point for callers that already use it.
func execute_state(game_state: GameState, primary_state: StateModel) -> void:
	execute_for_state(game_state, primary_state)


func resolve_attack(game_state: GameState, state: StateModel, base_strength: int) -> void:
	var attack_strength := maxi(0, base_strength + state.unrest_size)
	var available_troops := maxi(0, state.troops - state.exhaustedTroops)
	var troops_to_exhaust := mini(attack_strength, available_troops)
	state.exhaustTroops(troops_to_exhaust)

	if troops_to_exhaust < attack_strength:
		loose_region_rule.execute_for_state(game_state, state)
		return

	state.resetUnrest()
	state.addThropyToken()
	if game_state.elephant != null:
		elephant_redirect_rule.execute(game_state)


func get_event_modifier() -> int:
	if EventHelper.activeEvent == null:
		return 0
	return EventHelper.activeEvent.modifier
