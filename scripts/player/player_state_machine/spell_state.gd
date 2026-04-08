extends State

func physics_update(delta):
	var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	if input_vec != Vector2.ZERO:
		# slower movement
		player.input_movement.move(delta, 0.9)
	else:
		player.velocity.x = 0
		player.velocity.z = 0

func update(delta):
	player.apply_walk_visuals(delta, 0.5)
	player.apply_camera_tilt(delta * 0.5)
	# if player exits drawing mode → switch state
	if not player.is_drawing_spell:
		var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		
		if input_vec == Vector2.ZERO:
			state_machine.change_state("IdleState")
		else:
			state_machine.change_state("MoveState")
