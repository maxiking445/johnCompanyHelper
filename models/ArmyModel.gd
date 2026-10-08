extends Resource
class_name ArmyModel

@export_range(0, 20) var officers: int
@export_range(0, 20) var exhausted_officers: int
@export_range(0, 20) var regiments: int
@export_range(0, 20) var exhausted_regiments: int
@export var local_alliances: Array[LocalAllianceModel] = []


func available_strength() -> int:
	var strength := maxi(0, officers - exhausted_officers)
	strength += maxi(0, regiments - exhausted_regiments)
	for alliance in local_alliances:
		if alliance != null and alliance.purchased and not alliance.exhausted:
			strength += alliance.strength
	return strength


## Automatic choice: use regiments, then officers, then whole local alliances.
## A local alliance may exceed the remaining required strength; it cannot be split.
func exhaust_for_defense(required_strength: int, presidency_name: String) -> int:
	var exhausted_strength := 0
	var needed := maxi(0, required_strength)
	var regiments_to_exhaust := mini(needed, maxi(0, regiments - exhausted_regiments))
	exhausted_regiments += regiments_to_exhaust
	exhausted_strength += regiments_to_exhaust
	needed -= regiments_to_exhaust
	var officers_to_exhaust := mini(needed, maxi(0, officers - exhausted_officers))
	exhausted_officers += officers_to_exhaust
	exhausted_strength += officers_to_exhaust
	needed -= officers_to_exhaust
	for alliance in local_alliances:
		if needed <= 0:
			break
		if alliance == null or not alliance.purchased or alliance.exhausted:
			continue
		alliance.exhausted = true
		exhausted_strength += alliance.strength
		needed -= alliance.strength
	if exhausted_strength > 0:
		ActionManager.add_action(
			ActionFactory.exhaust_army_action(presidency_name, exhausted_strength)
		)
	return exhausted_strength


func remove_officer(presidency_name: String) -> void:
	if officers <= 0:
		return
	officers -= 1
	exhausted_officers = mini(exhausted_officers, officers)
	ActionManager.add_action(ActionFactory.remove_officer_action(presidency_name))
