extends GutTest

const BATTLE_RESOLVER := preload("res://rules/BattleResolver.gd")

var _resolver := BATTLE_RESOLVER.new()


func test_attacker_wins_with_greater_strength() -> void:
	var winner := _resolver.determine_winner(4, 3)

	assert_eq(winner, BATTLE_RESOLVER.Winner.ATTACKER)


func test_defender_wins_with_greater_strength() -> void:
	var winner := _resolver.determine_winner(2, 3)

	assert_eq(winner, BATTLE_RESOLVER.Winner.DEFENDER)


func test_defender_wins_ties() -> void:
	var winner := _resolver.determine_winner(3, 3)

	assert_eq(winner, BATTLE_RESOLVER.Winner.DEFENDER)
