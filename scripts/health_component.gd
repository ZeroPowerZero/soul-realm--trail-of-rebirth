@tool
class_name HealthComponent
extends Node

@export var settings: HealthComponentSettings:
	set(value):
		settings = value
		set_settings(settings)

var _settings: HealthComponentSettings

var _max_health: float
var _health: float

func take_damage(value: float) -> void:
	_health -= value
	
	if _health <= 0:
		get_parent().queue_free()

func full_health() -> void:
	_health = _max_health

func set_settings(value: HealthComponentSettings):
	_settings = value
	_max_health = _settings.max_health
func set_max_health(value: float) -> void:
	_max_health = value
func set_health(value: float) -> void:
	_health = value

func get_max_health() -> float:
	return _max_health
func get_health() -> float:
	return _health
