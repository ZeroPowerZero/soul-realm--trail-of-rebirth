class_name idleState
extends State

func physics_update(delta):
	if player.is_drawing_spell:
		state_machine.change_state("SpellState")
		return
	
	var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	player.input_movement.move(delta)
	if input_vec != Vector2.ZERO:
		state_machine.change_state("MoveState")
	
func update(delta):
	player.apply_walk_visuals(delta, 0.2)
	player.apply_camera_tilt(delta)
