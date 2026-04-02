class_name ApprenticeMage
extends MageBase

@export var spells_to_use: Array[String] = ["FireBall", "Ice Spikes"]

var attack_cooldown: float = 3.0
var time_since_last_attack: float = 0.0

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target_player):
		target_player = find_player()
		return
	
	# If we are currently casting, don't move or start a new spell
	if is_casting:
		velocity = Vector3.ZERO
		move_and_slide()
		return
		
	var dist_to_player = global_position.distance_to(target_player.global_position)
	
	if dist_to_player > attack_range:
		# Move towards player
		var dir = (target_player.global_position - global_position).normalized()
		dir.y = 0
		velocity = dir * movement_speed
		look_at(global_position + dir, Vector3.UP)
		move_and_slide()
	else:
		velocity = Vector3.ZERO
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
