class_name DashState
extends State

## Player is dashing — brief invulnerable burst of speed with visual juice.

var timer: float = 0.0
const DASH_DURATION := 0.2

func enter() -> void:
	timer = DASH_DURATION
	player.execute_dash()

	# --- Visual Juice ---
	# FOV punch (widen camera then snap back)
	player.camera_fov_punch(12.0, DASH_DURATION + 0.15)

	# Camera shake (subtle)
	player.camera_shake(0.03, DASH_DURATION)

func exit() -> void:
	# Ensure FOV is restored (safety net — fov_punch handles its own tween)
	pass

func physics_update(delta: float) -> void:
	timer -= delta

	if timer <= 0:
		# Smart exit: go to MoveState if player is still pressing movement keys
		var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		if input_vec != Vector2.ZERO:
			state_machine.change_state("MoveState")
		else:
			state_machine.change_state("IdleState")

func update(delta: float) -> void:
	# Reduced visuals during dash (speed feel)
	player.apply_walk_visuals(delta, 0.3)
