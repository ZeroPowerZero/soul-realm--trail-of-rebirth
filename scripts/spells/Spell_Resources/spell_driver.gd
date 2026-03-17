class_name SpellDriver
extends Resource

@export var _data: SpellData
@export var _coords: Array[Vector2]

# Setter And Getter Functions
func set_data(new_data: SpellData) -> void:
	_data = new_data
func set_coords(new_coords: Array[Vector2]) -> void:
	_coords = new_coords

func get_data() -> SpellData:
	return _data
func get_coords() -> Array[Vector2]:
	return _coords
