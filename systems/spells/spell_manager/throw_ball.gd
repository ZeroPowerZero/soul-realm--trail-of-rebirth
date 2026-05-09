class_name ThrowSpell
extends Node

@export var speed: float = 25.0

var _owner: Node3D

func move(delta: float):
	_owner.global_position -= _owner.global_basis.z * speed * delta

func change_owner(who: Node3D):
	_owner = who
