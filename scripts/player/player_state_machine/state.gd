class_name State

extends Node

var player
var state_machine

func _ready():
	player = get_parent().get_parent()

func enter():
	pass

func update(delta: float):
	pass

func physics_update(delta: float):
	pass

func exit():
	pass
