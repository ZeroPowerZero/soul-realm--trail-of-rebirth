class_name IdleState
extends State

## Player is standing still, not casting, not moving.

func enter() -> void:
	# Reset velocity to stop sliding
	player.velocity.x = move_toward(player.velocity.x, 0.0, 1.0)
	player.velocity.z = move_toward(player.velocity.z, 0.0, 1.0)

func physics_update(delta: float) -> void:
	# --- Priority transitions ---
	if player.is_drawing_spell:
		state_machine.change_state("SpellState")
		return

	# Fall detection
	if not player.is_on_floor():
		state_machine.change_state("FallState")
		return

	# Movement detection
	var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	player.input_movement.move(delta)

	if input_vec != Vector2.ZERO:
		state_machine.change_state("MoveState")

func update(delta: float) -> void:
	# Gentle idle breathing bob (very subtle)
	player.apply_walk_visuals(delta, 0.15)
	player.apply_camera_tilt(delta)
