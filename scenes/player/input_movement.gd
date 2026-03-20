class_name InputMovement
extends Node

@export var max_speed: float = 5
@export var acceleration: float = 6
@export var friction: float = 12

var _controller: CharacterBody3D

func _ready() -> void:
	_controller = get_parent()
	set_enable(false)

func _physics_process(delta: float) -> void:
	move(delta)

func move(delta: float) -> void:
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward").normalized()
	var direction: Vector3 = _controller.basis*Vector3(input.x, 0, input.y)
	
	if !is_equal_approx(direction.x, 0):
		_controller.velocity.x = move_toward(_controller.velocity.x, direction.x*max_speed, acceleration*delta)
	elif !is_equal_approx(_controller.velocity.x, 0):
		_controller.velocity.x = move_toward(_controller.velocity.x, 0.0, friction*delta)
	if !is_equal_approx(direction.z, 0):
		_controller.velocity.z = move_toward(_controller.velocity.z, direction.z*max_speed, acceleration*delta)
	elif !is_equal_approx(_controller.velocity.z, 0):
		_controller.velocity.z = move_toward(_controller.velocity.z, 0.0, friction*delta)
	
	_controller.move_and_slide()

func set_enable(enable: bool):
	set_physics_process(enable)
