class_name AimAssistComponent
extends Node

@export var homing_speed: float = 1.5 # Lowered value for a smoother curve
@export var max_range: float = 40.0
@export var max_angle_degrees: float = 60.0
@export var active: bool = true

var _target_enemy: Node3D = null
var _owner_node: Node3D = null

func setup(owner_node: Node3D, forward_dir: Vector3):
	_owner_node = owner_node
	_target_enemy = _find_best_target(forward_dir)

func _physics_process(delta: float):
	if active and is_instance_valid(_target_enemy) and is_instance_valid(_owner_node):
		var target_pos = _target_enemy.global_position + Vector3(0, 1, 0) # Aim at center mass
		var desired_dir = (target_pos - _owner_node.global_position).normalized()
		var current_dir = -_owner_node.global_basis.z
		
		# Gently steer towards the target
		var new_dir = current_dir.lerp(desired_dir, delta * homing_speed).normalized()
		
		# Prevent 'look_at' errors if new_dir and Vector3.UP are aligned
		if abs(new_dir.dot(Vector3.UP)) < 0.999:
			_owner_node.look_at(_owner_node.global_position + new_dir, Vector3.UP)

func _find_best_target(forward_dir: Vector3) -> Node3D:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var best_target = null
	var best_score = -INF
	var max_angle = cos(deg_to_rad(max_angle_degrees))
	
	# Fallback if no owner
	if not is_instance_valid(_owner_node):
		return null
	
	for e in enemies:
		var dir_to_enemy = (e.global_position - _owner_node.global_position).normalized()
		var dist = _owner_node.global_position.distance_to(e.global_position)
		
		if dist < max_range:
			var dot = forward_dir.dot(dir_to_enemy)
			# Only target enemies somewhat in front of the player
			if dot > max_angle:
				# Prioritize enemies more central to the crosshair (higher dot), but factor in distance
				var score = dot - (dist / max_range) * 0.5 
				if score > best_score:
					best_score = score
					best_target = e
					
	return best_target
