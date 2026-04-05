class_name MageBase
extends CharacterBody3D

@export var max_health: float = 100.0
@export var movement_speed: float = 3.0
@export var attack_range: float = 15.0

# Node references
var health_component: Node
var spell_controller: SpellController
var drawing_visualizer: EnemyDrawVisualizer

# State
var is_casting: bool = false
var target_player: Node3D = null

# Physics & Navigation
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var nav_agent: NavigationAgent3D

func _ready() -> void:
	add_to_group("Enemy")
	
	# Setting up health component dynamically if not added in scene
	if not has_node("HealthComponent"):
		var HealthScript = load("res://scripts/health_component.gd")
		if HealthScript:
			health_component = HealthScript.new()
			health_component.name = "HealthComponent"
			add_child(health_component)
			# Assuming health_component has a setup or max_health property
			if "max_health" in health_component:
				health_component.max_health = max_health
	else:
		health_component = get_node("HealthComponent")
	
	# Setting up spell controller
	spell_controller = SpellController.new()
	spell_controller.name = "SpellController"
	add_child(spell_controller)
	spell_controller.set_basis_node(self)
	spell_controller.set_spawn_node(self) # Firing from center/body
	
	# Setup Visualizer
	drawing_visualizer = EnemyDrawVisualizer.new()
	drawing_visualizer.name = "DrawingVisualizer"
	
	var billboard_node = find_child("SpellBillboard", true, false)
	if billboard_node and billboard_node is Sprite3D:
		drawing_visualizer.target_sprite = billboard_node
		
	add_child(drawing_visualizer)
	
	# Setup Navigation
	nav_agent = NavigationAgent3D.new()
	nav_agent.name = "NavigationAgent"
	# Avoid using avoidance for now to keep things simple and prevent drifting
	nav_agent.avoidance_enabled = false
	add_child(nav_agent)

func find_player() -> Node3D:
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		return players[0]
	return null

func get_spell_driver(spell_name: String) -> SpellDriver:
	if not Templates.spell_manager:
		return null
	for driver in Templates.spell_manager.get_spells():
		if driver.get_data().name == spell_name:
			return driver
	return null

func prepare_and_cast_spell(spell_name: String, draw_duration: float = 1.5) -> void:
	if is_casting: return
	
	var driver = get_spell_driver(spell_name)
	if not driver:
		push_warning("MageBase couldn't find spell: " + spell_name)
		return
		
	is_casting = true
	
	# Start visualizing the trace
	var coords = driver.get_coords()
	drawing_visualizer.start_drawing(coords, draw_duration)
	
	# Wait for drawing to finish
	await get_tree().create_timer(draw_duration + 0.2).timeout
	
	# Check if we were interrupted or died
	if not is_instance_valid(self):
		return
		
	# Clear drawing
	drawing_visualizer.clear_drawing()
	
	# Make sure we look at player before firing
	if is_instance_valid(target_player):
		var target_pos = target_player.global_position
		target_pos.y = global_position.y # Don't pitch up/down for body basis
		look_at(target_pos, Vector3.UP)
	
	# Fire the spell
	spell_controller.create_spell(driver)
	is_casting = false

func interrupt_cast() -> void:
	is_casting = false
	drawing_visualizer.clear_drawing()

func see_target(body: Node3D) -> void:
	target_player = body

func forget_target(body: Node3D) -> void:
	if target_player == body:
		target_player = null

func has_line_of_sight(target: Node3D) -> bool:
	if not is_instance_valid(target):
		return false
	var space_state = get_world_3d().direct_space_state
	# Cast from body center to target body center
	var origin_pos = global_position + Vector3.UP * 1.0
	var target_pos = target.global_position + Vector3.UP * 1.0
	
	var query = PhysicsRayQueryParameters3D.create(origin_pos, target_pos)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	if result and result.collider == target:
		return true
	return false
