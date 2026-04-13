class_name DeathState
extends State

## Player has died. Freezes input, drops camera, shows death menu.

const CAMERA_DROP_DURATION := 0.6
const DEATH_MENU_DELAY := 0.8

func enter() -> void:
	# Freeze all movement
	player.velocity = Vector3.ZERO
	player.is_drawing_spell = false

	# Release mouse for death menu
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# --- Visual: Camera death drop ---
	var tween = player.create_tween()
	# Tilt camera down and to the side
	tween.set_parallel(true)
	tween.tween_property(player.head, "rotation:x", deg_to_rad(-40.0), CAMERA_DROP_DURATION)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(player.head, "rotation:z", deg_to_rad(15.0), CAMERA_DROP_DURATION)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	# Slight FOV narrow (tunnel vision)
	tween.tween_property(player.camera, "fov", 50.0, CAMERA_DROP_DURATION)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

	# Red flash
	_flash_death()

	# Show death menu after delay
	player.get_tree().create_timer(DEATH_MENU_DELAY).timeout.connect(_show_death_menu)

func exit() -> void:
	# Reset camera in case of respawn
	player.head.rotation.x = 0.0
	player.head.rotation.z = 0.0
	player.camera.fov = 75.0

func physics_update(_delta: float) -> void:
	# Keep gravity so body doesn't float
	if not player.is_on_floor():
		player.velocity.y -= player.gravity * _delta
	else:
		player.velocity.y = -1.0

	player.velocity.x = 0
	player.velocity.z = 0
	player.move_and_slide()

func update(_delta: float) -> void:
	pass  # No visuals — player is dead

func handle_input(_event: InputEvent) -> void:
	pass  # Eat all input — player is dead

func _show_death_menu() -> void:
	var death_menu_scene = load("res://scenes/ui/death_menu.tscn")
	if death_menu_scene:
		var death_menu_instance = death_menu_scene.instantiate()
		player.add_child(death_menu_instance)

func _flash_death() -> void:
	var flash = ColorRect.new()
	flash.color = Color(0.8, 0.0, 0.0, 0.5)
	flash.anchors_preset = Control.PRESET_FULL_RECT
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	player.add_child(flash)

	var tween = player.create_tween()
	tween.tween_property(flash, "color:a", 0.15, 0.8).set_ease(Tween.EASE_OUT)
	# Keep a subtle red tint — don't free it, death is permanent until respawn
