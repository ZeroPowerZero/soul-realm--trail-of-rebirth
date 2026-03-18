class_name SpellController
extends Node

var _basis_node: Node3D

func create_spell(spell_driver: SpellDriver):
	if spell_driver._data.name == "FireBall":
		var new_spell = spell_driver.get_data().spell_scene.instantiate()
		create_fire_ball_spell(new_spell)
	
	elif spell_driver._data.name == "earth_spikes":
		var new_spell = spell_driver.get_data().spell_scene.instantiate()
		create_earth_spikes_spell(new_spell)

func create_fire_ball_spell(new_spell):
	new_spell.set_controller(self)
	get_tree().current_scene.add_child(new_spell)
	new_spell.global_position = _basis_node.global_position

func create_earth_spikes_spell(new_spell):
	new_spell.set_controller(self)
	get_tree().current_scene.add_child(new_spell)
	
	var look_direction = -_basis_node.global_basis.z
	var flat_direction = Vector3(look_direction.x, 0, look_direction.z).normalized()

	var spawn_distance = 5.0
	
	var spawn_pos = _basis_node.global_position + (flat_direction * spawn_distance) 
	
	spawn_pos.y = 0.0 

	new_spell.global_position = spawn_pos
	
	new_spell.look_at(spawn_pos + flat_direction)


#func create_earth_spikes_spell(new_spell):
	#new_spell.set_controller(self)
	#get_tree().current_scene.add_child(new_spell)
	#
	#var look_dir = -_basis_node.global_basis.z
	#var flat_dir = Vector3(look_dir.x, 0, look_dir.z).normalized()
	#
	#var spawn_distance = 3.0 
	#var spawn_pos = _basis_node.global_position + (flat_dir * spawn_distance)
	#spawn_pos.y = 0.0 # Force to ground level
	#
	#new_spell.global_position = spawn_pos
	#
	#var player_rotation_y = _basis_node.global_transform.basis.get_euler().y
	#new_spell.rotation.y = player_rotation_y
	
	#new_spell.rotate_object_local(Vector3.UP, deg_to_rad(90))

# Getter And Setter Functions
func set_basis_node(node: Node3D):
	_basis_node = node

func get_basis() -> Basis:
	return _basis_node.global_basis
