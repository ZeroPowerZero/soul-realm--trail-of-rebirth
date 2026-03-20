class_name AiMovement
extends Node

@export var max_speed: float = 3
@export var acceleration: float = 3
@export var friction: float = 7
@export var turn_speed: float = 12

var _controller: CharacterBody3D
var _coord: Vector3
var _acceleration_vector: float = 0
var _newyawquat: Quaternion

func _ready() -> void:
	set_physics_process(false)
	_controller = get_parent()

func go_to(new_coord: Vector3):
	_coord = _set_vector_y(new_coord)
	set_physics_process(true)

func stop():
	_coord = _set_vector_y(_controller.global_position)
	_acceleration_vector = 0
	_controller.velocity = _set_vector_y(Vector3.ZERO, _controller.velocity.y)
	if _controller.is_on_floor():
		set_physics_process(false)

func _set_vector_y(vec: Vector3, val: float = 0) -> Vector3:
	return Vector3(vec.x, val, vec.z)

func _physics_process(delta: float) -> void:
	var current_coord: Vector3 = _set_vector_y(_controller.global_position)
	var reached = current_coord.distance_squared_to(_coord) < 0.05
	
	var _target_acceleration: float = max_speed if !reached else 0.0
	var _current_acceleration_increase: float = acceleration if !reached else friction
	
	_acceleration_vector = move_toward(_acceleration_vector, _target_acceleration, _current_acceleration_increase * delta)
	
	if !_controller.is_on_floor():
		_controller.velocity += _controller.get_gravity() * delta
	
	var _direction = -(_coord-current_coord).normalized()
	if !reached:
		var yaw = atan2(_direction.x, _direction.z)
		_newyawquat = Quaternion.from_euler(Vector3(0, yaw, 0)).normalized()
		var quaternion_smoother: Quaternion = _controller.quaternion.slerp(_newyawquat, clamp(turn_speed*delta, 0.0, 1.0))
		_controller.basis = Basis(quaternion_smoother)
		
		_controller.velocity = _set_vector_y(-_controller.basis.z * _acceleration_vector, _controller.velocity.y)
	else:
		_controller.velocity = _set_vector_y(-_controller.basis.z * _acceleration_vector, _controller.velocity.y)
		
		if is_equal_approx(_acceleration_vector, 0) and _controller.is_on_floor():
			set_physics_process(false)
	
	_controller.move_and_slide()
