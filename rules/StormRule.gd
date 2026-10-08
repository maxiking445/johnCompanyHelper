class_name StormRule
extends Rule

"""
STORM

Roll the storm die to determine how many India events are drawn and which sea
zones are affected. In every affected zone, roll once for each player-owned
ship. Company and extra ships are ignored. Ships can escape, become damaged,
or sink; an already damaged ship sinks when it suffers further damage.
"""

var last_result: StormDice.Face = StormDice.Face.FOUR_A
var ship_results: Array[Dictionary] = []


func execute(game_state: GameState) -> void:
	var diceResult: StormDice.Face = RollHelper.rollStormDice()
	last_result = diceResult
	ship_results.clear()
	
	var zones_to_check: Array[SeaModel] = []
	match diceResult:
		StormDice.Face.FOUR_A, StormDice.Face.FOUR_B:
			game_state.set_events_to_draw(4)
		StormDice.Face.SOUTH_3:
			game_state.set_events_to_draw(3)
			zones_to_check.append(game_state.seaSouth)
		StormDice.Face.EAST_2:
			game_state.set_events_to_draw(2)
			zones_to_check.append(game_state.seaEast)
		StormDice.Face.WEST_2:
			game_state.set_events_to_draw(2)
			zones_to_check.append(game_state.seaWest)
		StormDice.Face.STORMS_ALL:
			game_state.set_events_to_draw(1)
			zones_to_check.append(game_state.seaSouth)
			zones_to_check.append(game_state.seaWest)
			zones_to_check.append(game_state.seaEast)
	
	print("Rolled StormDice ", StormDice.name(diceResult), " will check zones: ", zones_to_check)
	for zone in zones_to_check:
		_check_zone(zone, game_state)


func _check_zone(zone: SeaModel, game_state: GameState) -> void:
	# Sinking removes ships from the live array; iterate a snapshot.
	var ships := zone.ships.duplicate()
	for index in ships.size():
		var ship: ShipModel = ships[index]
		if ship.isCompanyShip() or ship.isExtraShip():
			continue

		var roll := RollHelper.rollD6()
		var outcome := "escaped" if roll <= 2 else ("sunk" if roll >= 5 or ship.isDamaged() else "damaged")
		ship_results.append({
			"ship": index + 1, "zone": game_state.get_sea_name(zone),
			"roll": roll, "outcome": outcome,
		})

		if roll <= 2:
			print(ship.display_name(), " escaped the Storm")
			continue
		elif roll == 3 ||  roll == 4:
			if ship.isDamaged(): 
				_sink_ship(ship, zone, game_state)
			else: 
				ship.damageShip(game_state.get_sea_name(zone))
		elif roll == 5 ||  roll == 6:
			_sink_ship(ship, zone, game_state)


func _sink_ship(ship: ShipModel, zone: SeaModel, game_state: GameState) -> void:
	zone.sink_ship(ship, game_state.get_sea_name(zone))
	print(ship.display_name(), " sunk due to the Storm")
