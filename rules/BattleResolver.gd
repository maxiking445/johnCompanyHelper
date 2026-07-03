class_name BattleResolver
extends RefCounted

"""
BATTLE RESOLUTION

Compare the final strength of both sides after every rule-specific modifier
has been applied. The attacker wins only when its strength is greater than the
defender's strength. The defender wins every tie.

This resolver determines only the winner. Rule-specific consequences such as
Region Loss, tower removal, trophies, or empire growth remain in their rules.
"""

enum Winner {
	ATTACKER,
	DEFENDER,
}


func determine_winner(attack_strength: int, defense_strength: int) -> Winner:
	if attack_strength > defense_strength:
		return Winner.ATTACKER
	return Winner.DEFENDER
