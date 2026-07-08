@tool
extends Node2D


@export_range(0, 99) var extra_ships: int = 0:
	set(value):
		extra_ships = value
		update_counts()

@export_range(0, 99) var player_ships: int = 0:
	set(value):
		player_ships = value
		update_counts()

@export_range(0, 99) var damaged_player_ships: int = 0:
	set(value):
		damaged_player_ships = value
		update_counts()

@export_range(0, 99) var company_ships: int = 0:
	set(value):
		company_ships = value
		update_counts()


func _ready() -> void:
	update_counts()


func update_counts() -> void:
	if not is_node_ready():
		return

	%ExtraCount.text = str(extra_ships)
	%PlayerCount.text = str(player_ships)
	%DamagedPlayerCount.text = str(damaged_player_ships)
	%CompanyCount.text = str(company_ships)


func set_counts(extra: int, player: int, damaged_player: int, company: int) -> void:
	extra_ships = extra
	player_ships = player
	damaged_player_ships = damaged_player
	company_ships = company
