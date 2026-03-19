class_name SpellController
extends Node

var basis_node: Node3D

func create_spell(spell_driver: SpellDriver):
	var new_spell = spell_driver.get_data().spell_scene.instantiate()
	new_spell.set_controller(self)
	get_tree().current_scene.add_child(new_spell)

# Getter And Setter Functions
func set_basis_node(node: Node3D):
	basis_node = node
func get_basis() -> Basis:
	return basis_node.global_basis
