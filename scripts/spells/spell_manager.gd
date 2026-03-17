class_name SpellManager
extends Node

@export var fireball_scene : PackedScene
@export var rock_spikes_scene : PackedScene


func cast_fireball(caster:Node3D, direction:Vector3):

	var spell = fireball_scene.instantiate()
	get_tree().current_scene.add_child(spell)

	spell.global_position = caster.global_position + Vector3()
	spell.initialize(direction)



func cast_rock_spikes(target_position:Vector3):

	var spell = rock_spikes_scene.instantiate()
	get_tree().current_scene.add_child(spell)

	spell.global_position = target_position
