class_name StatUpgradeData
extends UpgradeData

enum StatType { MAX_HEALTH, MAX_MANA, MANA_REGEN, SPEED }

@export var stat_type: StatType = StatType.MAX_HEALTH
@export var increase_amount: float = 20.0

func apply_upgrade(player: Node) -> void:
	match stat_type:
		StatType.MAX_HEALTH:
			if player.has_node("HealthComponent"):
				player.get_node("HealthComponent").max_health += increase_amount
		StatType.MAX_MANA:
			if player.has_node("ManaComponent"):
				player.get_node("ManaComponent").max_mana += increase_amount
		StatType.MANA_REGEN:
			if player.has_node("ManaComponent"):
				player.get_node("ManaComponent").regen_rate += increase_amount
		StatType.SPEED:
			if player.has_node("InputMovement"):
				player.get_node("InputMovement").max_speed += increase_amount
