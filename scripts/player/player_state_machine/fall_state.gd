class_name FallState
extends State

## Player is airborne (not on floor). Provides reduced air control.

const AIR_CONTROL := 0.4  # Multiplier for movement while airborne
const LAND_SHAKE_INTENSITY := 0.06
const LAND_SHAKE_DURATION := 0.12

var _was_falling: bool = false
var _fall_start_y: float = 0.0

func enter() -> void:
	_was_falling = true
	_fall_start_y = player.global_position.y

func exit() -> void:
	if _was_falling:
		# Landing impact visuals based on fall distance
		var fall_distance = _fall_start_y - player.global_position.y
		if fall_distance > 1.0:
			var intensity = clamp(fall_distance * 0.03, LAND_SHAKE_INTENSITY, 0.2)
			var duration = clamp(fall_distance * 0.04, LAND_SHAKE_DURATION, 0.3)
			player.camera_shake(intensity, duration)
			player.landing_bob(clamp(fall_distance * 0.015, 0.02, 0.08))
			_spawn_landing_dust()

	_was_falling = false

func physics_update(delta: float) -> void:
	# Apply gravity
	if not player.is_on_floor():
		player.velocity.y -= player.gravity * delta

	# Air control (reduced movement authority)
	var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if input_vec != Vector2.ZERO:
		player.input_movement.move(delta, AIR_CONTROL)
	else:
		player.move_and_slide()

	# Landing detection
	if player.is_on_floor():
		if input_vec != Vector2.ZERO:
			state_machine.change_state("MoveState")
		else:
			state_machine.change_state("IdleState")

func update(delta: float) -> void:
	player.apply_camera_tilt(delta * 0.5)

func _spawn_landing_dust() -> void:
	# Emit landing dust particles if available
	if player.has_node("LandingDust"):
		var dust = player.get_node("LandingDust") as GPUParticles3D
		if dust:
			dust.restart()
			dust.emitting = true
