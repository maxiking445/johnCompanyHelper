extends Rule
class_name RebellionRule

const BATTLE_RESOLVER := preload("res://rules/BattleResolver.gd")

"""
If the attacker is a dominated region, resolve a Rebellion. Only the
attacking region and the region dominating it contribute their strength.
If the attacker's strength plus the event modifier is greater than the
defender's strength, the Rebellion succeeds; otherwise it fails.

On success, the attacker becomes sovereign, returns its empire flag and
closes every open order. If all orders are already closed, resolve a Cascade.
On failure, remove one tower level from the defending capital.
"""

var cascade_rule := CascadeRule.new()
var battle_resolver := BATTLE_RESOLVER.new()

func execute(game_state: GameState) -> void:
	print("Executing RebellionRule ...")
	if game_state == null or game_state.elephant == null:
		push_error("RebellionRule needs a game state with an Elephant.")
		return
	if not game_state.elephant.is_on_border():
		push_error("A Rebellion requires the Elephant to be on a border.")
		return

	var attacker := game_state.findStateByLocation(
		game_state.elephant.get_backward_state()
	)
	var defender := game_state.findStateByLocation(
		game_state.elephant.get_facing_state()
	)
	execute_detail(game_state, attacker, defender)


func execute_detail( game_state: GameState, attacker: StateModel, defender: StateModel) -> void:
	if game_state == null or attacker == null or defender == null:
		push_error("RebellionRule needs a game state, attacker and defender.")
		return
	if not attacker.isDominated or attacker.isDominatedBy != defender:
		push_error("The rebellion attacker must be dominated by the defender.")
		return

	var attack_strength := calculate_attack_strength(attacker)
	var defense_strength := defender.towerLevel
	var attacker_name := StateType.name(attacker.location)
	var defender_name := StateType.name(defender.location)
	ActionManager.add_action(
		ActionFactory.battle_started_action(
			attacker_name, defender_name, attack_strength, defense_strength
		)
	)
	var winner := battle_resolver.determine_winner(
		attack_strength, defense_strength
	)
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
		resolve_success(game_state, attacker)
	else:
		defender.removeTowerLevel()


func calculate_attack_strength(attacker: StateModel) -> int:
	var modifier := 0
	if EventHelper.activeEvent != null:
		modifier = EventHelper.activeEvent.modifier
	return attacker.towerLevel + modifier


func resolve_success(game_state: GameState, attacker: StateModel) -> void:
	attacker.become_sovereign_after_rebellion()

	if game_state.areAllOrderClosed(attacker.location):
		cascade_rule.execute_location(game_state, attacker.location)
	else:
		game_state.closeAllOrders(attacker.location)
