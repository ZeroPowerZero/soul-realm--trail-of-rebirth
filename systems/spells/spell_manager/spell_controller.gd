class_name SpellController
extends Node

var basis_node: Node3D
var spawn_node: Node3D

func create_spell(spell_driver: SpellDriver):
	var new_spell = spell_driver.get_data().spell_scene.instantiate()
	new_spell.set_controller(self)
	new_spell.set_driver(spell_driver);
	get_tree().current_scene.add_child(new_spell)
	
	if has_node("/root/AudioManager"):
		AudioManager.play_spell_sfx()

# Getter And Setter Functions
func set_basis_node(node: Node3D):
	basis_node = node
func get_basis() -> Basis:
	return basis_node.global_basis

func set_spawn_node(node: Node3D):
	spawn_node = node

func get_forward_direction() -> Vector3:
	return -basis_node.global_transform.basis.z

func get_spawn_position() -> Vector3:
	return spawn_node.global_position + get_forward_direction() * 1.0

func get_spawn_node() -> Node3D:
	return spawn_node
