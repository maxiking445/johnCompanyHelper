class_name StormRule
extends Rule

func execute(game_state: GameState) -> void:
	var diceResult: StormDice = RollHelper.rollStormDice()
	
	var zones_to_check: Array[SeaModel] = []
	match diceResult:
		StormDice.Face.FOUR_A, StormDice.Face.FOUR_B:
			pass
		StormDice.Face.SOUTH_3:
			zones_to_check.append(game_state.seaSouth)
		StormDice.Face.EAST_2:
			zones_to_check.append(game_state.seaEast)
		StormDice.Face.WEST_2:
			zones_to_check.append(game_state.seaWest)
		StormDice.Face.STORMS_ALL:
			zones_to_check.append(game_state.seaSouth)
			zones_to_check.append(game_state.seaWest)
			zones_to_check.append(game_state.seaEast)
	
	print("Rolled StormDice ", diceResult, " will check zones: ", zones_to_check)
	for zone in zones_to_check:
		_check_zone(zone, game_state)


func _check_zone(zone: SeaModel, game_state: GameState) -> void:
	for ship: ShipModel in zone.ships:
		if ship.isCompanyShip() or ship.isExtraShip():
			continue

		var roll := RollHelper.rollD6()

		if roll <= 2:
			print("Ship from ", ship.owner  , "escaped the Storm")
			continue
		elif roll == 3 ||  roll == 4:
			if ship.isDamaged(): 
				_sink_ship(ship, zone, game_state)
			else: 
				ship.damageShip()
		elif roll == 5 ||  roll == 6:
			_sink_ship(ship, zone, game_state)


func _sink_ship(ship: ShipModel, zone: SeaModel, game_state: GameState) -> void:
	log(zone.ships.size())
	zone.ships.erase(ship)
	print("Ship sunk from ", ship.owner  , "due to the Storm")
	log(zone.ships.size())
