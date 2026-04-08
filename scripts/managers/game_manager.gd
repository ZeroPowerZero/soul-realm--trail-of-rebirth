extends Node

signal xp_updated(current: float, required: float)
signal leveled_up(new_level: int)

var current_xp: float = 0.0
var xp_required: float = 100.0
var level: int = 1

func add_xp(amount: float) -> void:
	current_xp += amount
	while current_xp >= xp_required:
		level_up()
	xp_updated.emit(current_xp, xp_required)

func level_up() -> void:
	current_xp -= xp_required
	level += 1
	xp_required *= 1.2 # Increase required XP for next level by 20%
	leveled_up.emit(level)
