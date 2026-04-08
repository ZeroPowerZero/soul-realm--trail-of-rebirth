#class_name UpgradeManager
extends Node

@export var upgrade_pool: Array[UpgradeData] = []

func get_random_upgrades(player_upgrade_component: UpgradeComponent, count: int = 3) -> Array[UpgradeData]:
	var available_upgrades: Array[UpgradeData] = []
	var total_weight: float = 0.0
	
	for upgrade in upgrade_pool:
		if not player_upgrade_component.has_maxed_upgrade(upgrade):
			available_upgrades.append(upgrade)
			total_weight += upgrade.weight
			
	var selected_upgrades: Array[UpgradeData] = []
	var attempts = 0
	
	while selected_upgrades.size() < count and selected_upgrades.size() < available_upgrades.size() and attempts < 100:
		attempts += 1
		var random_val = randf() * total_weight
		var current_weight = 0.0
		
		for upgrade in available_upgrades:
			current_weight += upgrade.weight
			if random_val <= current_weight:
				if not selected_upgrades.has(upgrade):
					selected_upgrades.append(upgrade)
				break
				
	return selected_upgrades
