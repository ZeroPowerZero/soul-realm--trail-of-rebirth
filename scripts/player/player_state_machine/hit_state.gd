class_name HitState
extends State

## Player just took damage — brief stagger with visual feedback.

const STAGGER_DURATION := 0.15
const INVULN_DURATION := 0.4  # Brief invulnerability after hit

var timer: float = 0.0

func enter() -> void:
	timer = STAGGER_DURATION

	# --- Visual Juice ---
	# Camera shake on hit
	player.camera_shake(0.12, STAGGER_DURATION + 0.1)

	# Velocity knockback (slight)
	player.velocity.x *= 0.3
	player.velocity.z *= 0.3

	# Red vignette flash
	_flash_damage()

func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	timer -= delta

	# Apply friction to slow down during stagger
	player.velocity.x = move_toward(player.velocity.x, 0.0, 8.0 * delta)
	player.velocity.z = move_toward(player.velocity.z, 0.0, 8.0 * delta)

	# Gravity
	if not player.is_on_floor():
		player.velocity.y -= player.gravity * delta

	player.move_and_slide()

	if timer <= 0:
		# Return to appropriate state
		var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		if player.is_drawing_spell:
			state_machine.change_state("SpellState")
		elif input_vec != Vector2.ZERO:
			state_machine.change_state("MoveState")
		else:
			state_machine.change_state("IdleState")

func update(delta: float) -> void:
	# Subtle wobble during stagger
	player.apply_camera_tilt(delta * 2.0)

func _flash_damage() -> void:
	# Create a brief red overlay flash using a ColorRect
	# This is a lightweight approach — create, flash, and free
	var flash = ColorRect.new()
	flash.color = Color(0.9, 0.1, 0.1, 0.3)
	flash.anchors_preset = Control.PRESET_FULL_RECT
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Add to the player's viewport
	player.add_child(flash)

	# Fade out and remove
	var tween = player.create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_callback(flash.queue_free)
