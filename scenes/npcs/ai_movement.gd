@tool
class_name AIMOVEMENT
extends Node

@export var settings: AIMOVEMENTSETTINGS:
	set(value):
		settings = value
		set_settings(value)

var _settings

var _max_speed: float
var _acceleration: float
var _friction: float
var _turn_speed: float

var _controller: CharacterBody3D
var _coord: Vector3
var _current_coord: Vector3
var _acceleration_vector: float = 0
var _newyawquat: Quaternion

func _ready() -> void:
	set_physics_process(false)
	_controller = get_parent()

func go_to(new_coord: Vector3):
	_coord = _set_vector_y(new_coord)
	_current_coord = _set_vector_y(_controller.position)
	set_physics_process(true)

func _set_vector_y(vec: Vector3, val: float = 0) -> Vector3:
	return Vector3(vec.x, val, vec.z)

func _physics_process(delta: float) -> void:
	var reached = _current_coord.distance_squared_to(_coord) < 0.05
	
	var _target_acceleration: float = _max_speed if !reached else 0.0
	var _current_acceleration_increase: float = _acceleration if !reached else _friction
	
	_acceleration_vector = move_toward(_acceleration_vector, _target_acceleration, _current_acceleration_increase * delta)
	
	if !_controller.is_on_floor():
		_controller.velocity += _controller.get_gravity() * delta
	
	var _direction = -(_coord-_controller.position).normalized()
	if !reached:
		var yaw = atan2(_direction.x, _direction.z)
		_newyawquat = Quaternion.from_euler(Vector3(0, yaw, 0)).normalized()
		var quaternion_smoother: Quaternion = _controller.quaternion.slerp(_newyawquat, _turn_speed*delta)
		_controller.basis = Basis(quaternion_smoother)
		
		_controller.velocity = _set_vector_y(-Basis(_newyawquat).z * _acceleration_vector, _controller.velocity.y)
		_current_coord = _set_vector_y(_controller.position)
	else:
		_controller.velocity = _set_vector_y(-Basis(_newyawquat).z * _acceleration_vector, _controller.velocity.y)
		
		if is_equal_approx(_acceleration_vector, 0) and _controller.is_on_floor():
			set_physics_process(false)
	
	_controller.move_and_slide()

func set_settings(new_settings: AIMOVEMENTSETTINGS):
	_settings = new_settings
	_max_speed = _settings.max_speed
	_acceleration = _settings.acceleration
	_friction = _settings.friction
	_turn_speed = _settings.turn_speed
