extends Node

const SAVE_PATH: String = "user://spell_templates.json"
const MATCH_THRESHOLD: float = 60.0 # Adjust this: lower is stricter, higher is more forgiving

# Stores our loaded spells: { "Fireball": [Vector2, Vector2...], "Shield": [...] }
var saved_spells: Dictionary = {}

func _ready() -> void:
	#print(ProjectSettings.globalize_path("user://spell_templates.json"))
	load_spells()

# ==========================================================
# SAVE & LOAD SYSTEM
# ==========================================================
func save_new_spell(spell_name: String, normalized_points: Array[Vector2]) -> void:
	saved_spells[spell_name] = normalized_points
	_save_to_disk()
	print("Spell saved: ", spell_name)

func _save_to_disk() -> void:
	var data_to_save: Dictionary = {}
	
	# Convert Vector2 arrays into standard dictionaries for JSON saving
	for spell_name in saved_spells:
		var points_array: Array[Dictionary] = []
		for p in saved_spells[spell_name]:
			points_array.append({"x": p.x, "y": p.y})
		data_to_save[spell_name] = points_array
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data_to_save, "\t"))

func load_spells() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	
	if data and typeof(data) == TYPE_DICTIONARY:
		saved_spells.clear()
		# Convert JSON dictionaries back into Vector2 arrays
		for spell_name in data:
			var points: Array[Vector2] = []
			for p_dict in data[spell_name]:
				points.append(Vector2(p_dict["x"], p_dict["y"]))
			saved_spells[spell_name] = points
		print("Loaded ", saved_spells.size(), " spells from disk.")

# ==========================================================
# RECOGNITION SYSTEM
# ==========================================================
func recognize_spell(drawn_points: Array[Vector2]) -> String:
	if saved_spells.is_empty():
		return "No spells learned yet!"
		
	var best_match: String = ""
	var best_score: float = INF
	
	for spell_name in saved_spells:
		var score = _calculate_average_distance(drawn_points, saved_spells[spell_name])
		if score < best_score:
			best_score = score
			best_match = spell_name
			
	if best_score <= MATCH_THRESHOLD:
		return best_match
	else:
		return "Spell Failed (Score: " + str(snapped(best_score, 0.1)) + ")"

func _calculate_average_distance(points1: Array[Vector2], points2: Array[Vector2]) -> float:
	# Compares the distance between each corresponding point in the two normalized arrays
	var total_distance: float = 0.0
	var point_count = min(points1.size(), points2.size())
	
	for i in range(point_count):
		total_distance += points1[i].distance_to(points2[i])
		
	return total_distance / point_count
