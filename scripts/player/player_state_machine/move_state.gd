class_name moveState
extends State

func physics_update(delta):
	var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	if input_vec == Vector2.ZERO:
		state_machine.change_state("IdleState")
		return

	player.input_movement.move(delta)

func update(delta):
	player.apply_walk_visuals(delta, 1.0)
	player.apply_camera_tilt(delta)
