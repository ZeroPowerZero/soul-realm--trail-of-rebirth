class_name ApprenticeMage
extends MageBase

@export var spells_to_use: Array[String] = ["FireBall", "Ice Spikes"]

var attack_cooldown: float = 3.0
var time_since_last_attack: float = 0.0

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	if not is_instance_valid(target_player):
		target_player = find_player()
		if not is_on_floor():
			move_and_slide()
		return
	
	# If we are currently casting, don't move or start a new spell
	if is_casting:
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return
	
	# Update navigation target
	nav_agent.target_position = target_player.global_position
	
	var dist_to_player = global_position.distance_to(target_player.global_position)
	var has_los = has_line_of_sight(target_player)
	
	# Move if out of range OR if no line of sight
	if dist_to_player > attack_range or not has_los:
		# Move towards player using pathfinding
		var next_location = nav_agent.get_next_path_position()
		var dir = (next_location - global_position).normalized()
		dir.y = 0
		
		if dir.length_squared() > 0.001:
			velocity.x = dir.x * movement_speed
			velocity.z = dir.z * movement_speed
			look_at(global_position + dir, Vector3.UP)
		else:
			velocity.x = 0
			velocity.z = 0
		
		move_and_slide()
	else:
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		
		# Look at player while idle
		var target_pos = target_player.global_position
		target_pos.y = global_position.y
		look_at(target_pos, Vector3.UP)
		
		# Try to cast
		time_since_last_attack += delta
		if time_since_last_attack >= attack_cooldown:
			time_since_last_attack = 0.0
			var random_spell = spells_to_use[randi() % spells_to_use.size()]
			prepare_and_cast_spell(random_spell, 1.5) # 1.5 second cast delay

# Add interrupt on taking damage if the health system sends a signal or calls a func
func _on_damage_taken(_amount: float):
	interrupt_cast()
