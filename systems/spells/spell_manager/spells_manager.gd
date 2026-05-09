class_name SpellsManager
extends Resource

@export var _spells: Array[SpellDriver]

func new_spell_driver(new_spell: SpellData, new_coords: Array[Vector2]):
	var _new_spell_driver = SpellDriver.new()
	_new_spell_driver.set_data(new_spell)
	_new_spell_driver.set_coords(new_coords)
	_spells.append(_new_spell_driver)

func get_spells() -> Array[SpellDriver]:
	return _spells
