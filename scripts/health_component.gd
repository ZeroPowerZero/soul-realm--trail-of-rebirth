class_name HealthComponent
extends Node

@export var max_health: float = 50

var _health: float

func take_damage(value: float) -> void:
	_health -= value
	
	if _health <= 0:
		get_parent().queue_free()

# Getter and Setter
func set_max_health(value: float) -> void:
	max_health = value
func set_health(value: float) -> void:
	_health = value

func get_max_health() -> float:
	return max_health
func get_health() -> float:
	return _health
