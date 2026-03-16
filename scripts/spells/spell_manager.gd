class_name SpellManager
extends Node

@export var fireball_scene : PackedScene
@export var rock_spikes_scene : PackedScene
@onready var camera: Camera3D = $"../head/Camera3D"

@onready var pen_0: Node3D = $"../head/Camera3D/view_model/Pen_0"

func cast_fireball(caster:Node3D, direction:Vector3):

	var spell = fireball_scene.instantiate()
	get_tree().current_scene.add_child(spell)

	spell.global_position = caster.global_position + Vector3()
	spell.initialize(direction)



func cast_rock_spikes(target_position:Vector3):

	var spell = rock_spikes_scene.instantiate()
	get_tree().current_scene.add_child(spell)

	spell.global_position = target_position


func _on_spell_drawing_controller_spell_manager_call(spell_name: String) -> void:
	var dir = -camera.global_transform.basis.z
	cast_fireball(pen_0, dir)
