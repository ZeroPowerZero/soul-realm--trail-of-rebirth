class_name MoveState
extends State

## Player is actively moving on the ground.

func physics_update(delta: float) -> void:
	# Fall detection
	if not player.is_on_floor():
		state_machine.change_state("FallState")
		return

	# Spell mode override
	if player.is_drawing_spell:
		state_machine.change_state("SpellState")
		return

	var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	if input_vec == Vector2.ZERO:
		state_machine.change_state("IdleState")
		return

	player.input_movement.move(delta)

func update(delta: float) -> void:
	player.apply_walk_visuals(delta, 1.0)
	player.apply_camera_tilt(delta)
