class_name AIMOVEMENT
extends Node

var _npc_manager: NPCMANAGER
var _controller: CharacterBody3D

var _coord: Vector3
var _direction: Vector3
var _acceleration_vector: float = 0

func _init(who: CharacterBody3D, npc_manager: NPCMANAGER):
	_controller = who
	_npc_manager = npc_manager

func _ready() -> void:
	set_physics_process(false)

func go_to(new_coord: Vector3):
	_coord = new_coord
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	var reached = _controller.position.is_equal_approx(_coord)
	
	var max_speed = _npc_manager.get_resource().max_speed
	var acceleration = _npc_manager.get_resource().acceleration
	var friction = _npc_manager.get_resource().acceleration
	
	var target_acceleration: float = max_speed if !reached else 0.0
	var current_acceleration_increase: float = acceleration if !reached else friction
	
	_acceleration_vector = move_toward(acceleration, target_acceleration, current_acceleration_increase * delta)
	
	if !reached:
		_controller.position = _controller.position.move_toward(_coord, _acceleration_vector * delta)
	else:
		_controller.position += _direction * _acceleration_vector
		
		if is_equal_approx(_acceleration_vector, 0):
			set_physics_process(false)
