class_name UpgradeComponent
extends Node

# Dictionary tracking the current level of applied upgrades -> { "id" : level }
var current_upgrades: Dictionary = {}

func apply_upgrade(upgrade_data: UpgradeData):
	var current_level = current_upgrades.get(upgrade_data.id, 0)
	
	if current_level < upgrade_data.max_level:
		upgrade_data.apply_upgrade(get_parent())
		current_upgrades[upgrade_data.id] = current_level + 1
		print("Applied upgrade: ", upgrade_data.name, " (Level ", current_upgrades[upgrade_data.id], ")")
	else:
		print("Upgrade ", upgrade_data.name, " is already at max level.")

func has_maxed_upgrade(upgrade_data: UpgradeData) -> bool:
	return current_upgrades.get(upgrade_data.id, 0) >= upgrade_data.max_level
