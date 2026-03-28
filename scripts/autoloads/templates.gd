extends Node

const SAVE_PATH: String = "user://spells_manager.res"
const MATCH_THRESHOLD: float = 60.0

var spell_manager: SpellsManager

func _ready() -> void:
	load_spells()

func save_new_spell(resource: SpellData, coords: Array[Vector2]):
	spell_manager.new_spell_driver(resource, coords)
	
	print("spells: ", spell_manager.get_spells())
	var error = ResourceSaver.save(spell_manager, SAVE_PATH)
	
	if error != OK:
		print("Couldn't save: ", error)
	else:
		print("saved succesfully: ", spell_manager)

func save_spells():
	print("spells: ", spell_manager.get_spells())
	var error = ResourceSaver.save(spell_manager, SAVE_PATH)
	if error != OK:
		print("Couldn't save: ", error)
	else:
		print("saved succesfully: ", spell_manager)

func load_spells():
	var current_game_data = load_data(SAVE_PATH) as SpellsManager
	
	if current_game_data != null:
		spell_manager = current_game_data
		print("file loaded succesfully: ", spell_manager.get_spells())
	else:
		print("File couldn't find, please create one.")
		spell_manager = SpellsManager.new()

func load_data(file_path: String) -> Resource:
	if !FileAccess.file_exists(file_path):
		return null
	var loaded_resource = ResourceLoader.load(file_path)
	
	if loaded_resource != null:
		return loaded_resource
	else:
		printerr("File is broken or unreadable!")
		return null

func recognize_spell(drawn_points: Array[Vector2]) -> SpellDriver:
	if spell_manager.get_spells().is_empty():
		return null
	
	var best_match: SpellDriver
	var best_score: float = INF
	
	for spell in spell_manager.get_spells():
		var score = _calculate_average_distance(drawn_points, spell.get_coords())
		if score < best_score:
			best_score = score
			best_match = spell
	
	if best_score <= MATCH_THRESHOLD:
		return best_match
	else:
		return null

func _calculate_average_distance(points1: Array[Vector2], points2: Array[Vector2]) -> float:
	var total_distance: float = 0.0
	var point_count = min(points1.size(), points2.size())
	
	for i in range(point_count):
		total_distance += points1[i].distance_to(points2[i])
	
	return total_distance / point_count
