class_name ManaComponent
extends Node

@export var max_mana := 100
var current_mana :float = 100
@export var regen_rate := 5.0

func _process(delta):
	current_mana = min(current_mana + regen_rate * delta, max_mana)

func spend(amount: float) -> bool:
	if current_mana >= amount:
		current_mana -= amount
		return true
	return false
