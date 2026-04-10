class_name HealthComponent
extends Node

signal died
signal health_changed(new_health: float, max_health: float)

@export var max_health: float = 10

var _health: float

func _ready() -> void:
	_health = max_health

func take_damage(value: float) -> void:
	_health -= value
	health_changed.emit(_health, max_health)
	
	if _health <= 0:
		print("you died : bitch")
		died.emit()
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
