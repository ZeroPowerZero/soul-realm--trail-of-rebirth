extends Node3D

@export var speed : float = 25.0
@export var max_distance : float = 40.0

var direction : Vector3
var start_position : Vector3


func initialize(dir:Vector3):

	direction = dir.normalized()
	start_position = global_position

	# make fireball face direction
	#look_at(global_position + direction)


func _physics_process(delta):

	global_position += direction * speed * delta

	var travelled = start_position.distance_to(global_position)

	if travelled >= max_distance:
		queue_free()
