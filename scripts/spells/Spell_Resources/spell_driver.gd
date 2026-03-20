class_name SpellDriver
extends Resource

@export var _data: SpellData
@export var _coords: Array[Vector2]
@export var _damage: float = 10
@export var _level: int = 1
@export var _exp: float = 0

# Setter And Getter Functions
func set_data(new_data: SpellData) -> void:
	_data = new_data
func set_coords(new_coords: Array[Vector2]) -> void:
	_coords = new_coords
func set_damage(new_damage: float) -> void:
	_damage = new_damage
func set_level(new_level: int) -> void:
	_level = new_level
func set_exp(new_exp: float) -> void:
	_exp = new_exp

func get_data() -> SpellData:
	return _data
func get_coords() -> Array[Vector2]:
	return _coords
func get_damage() -> float:
	return _damage
func get_level() -> int:
	return _level
func get_exp() -> float:
	return _exp
