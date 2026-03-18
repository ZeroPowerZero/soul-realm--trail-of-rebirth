class_name HealthComponent
extends Node

@export var _max_health: float = 100
@export var _health: float = 100

func take_damage(value: float) -> void:
	_health -= value
	
	if _health <= 0:
		get_parent().queue_free()

func get_full_health() -> void:
	_health = _max_health

func set_max_health(value: float) -> void:
	_max_health = value
func set_health(value: float) -> void:
	_health = value

func get_max_health() -> float:
	return _max_health
func get_health() -> float:
	return _health
