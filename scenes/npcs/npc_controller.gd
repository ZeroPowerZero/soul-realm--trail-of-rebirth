extends CharacterBody3D

@onready var tres_file: NPC_RESOURCE = preload("res://scenes/npcs/npc_resources/apprentice_mage.tres")

var npc_manager: NPCMANAGER
var ai_movement: AIMOVEMENT

func _ready() -> void:
	npc_manager = NPCMANAGER.new(tres_file)
	ai_movement = AIMOVEMENT.new(self, npc_manager)
	add_child(ai_movement)
	
	go_random_points()

func go_random_points():
	var new_coord: Vector3 = Vector3(randf_range(0, 10), position.y, randf_range(0, 10))
	ai_movement.go_to(new_coord)
	await get_tree().create_timer(randf_range(0.5, 3)).timeout
	go_random_points()
