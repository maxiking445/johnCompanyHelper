extends Node

var rules: Dictionary = {}

func register_rule(rule_name: String, rule: Resource) -> void:
	rules[rule_name] = rule

func execute_rule(rule_name: String, game_state: GameState) -> void:
	if not rules.has(rule_name):
		push_error("Rule not found: " + rule_name)
		return

	rules[rule_name].execute(game_state)
