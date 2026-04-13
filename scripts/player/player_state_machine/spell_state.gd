class_name SpellState
extends State

## Player is in spell-drawing mode. Movement is slowed, camera is slightly zoomed.

const SPELL_ZOOM_FOV := 65.0  # Slightly tighter than default
var _original_fov: float = 75.0

func enter() -> void:
	_original_fov = player.camera.fov
	# Zoom in slightly for spell-drawing focus
	player.camera_zoom(SPELL_ZOOM_FOV, 0.3)

func exit() -> void:
	# Restore original FOV
	player.camera_zoom(_original_fov, 0.25)

func physics_update(delta: float) -> void:
	var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	if input_vec != Vector2.ZERO:
		# Slower movement while drawing spells
		player.input_movement.move(delta, 0.9)
	else:
		player.velocity.x = 0
		player.velocity.z = 0

func update(delta: float) -> void:
	player.apply_walk_visuals(delta, 0.5)
	player.apply_camera_tilt(delta * 0.5)

	# If player exits drawing mode → switch state
	if not player.is_drawing_spell:
		var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		if input_vec == Vector2.ZERO:
			state_machine.change_state("IdleState")
		else:
			state_machine.change_state("MoveState")
