class_name Player
extends CharacterBody3D

@onready var head: Node3D = $head
@onready var drawing_container: Control = $DrawingCanvas/MarginContainer/SubViewportContainer
@onready var camera: Camera3D = $head/Camera3D
@onready var pen_0: Node3D = $head/Camera3D/view_model/Pen_0
@onready var spell_draw_limit_timer: Timer = $SpellDrawLimitTimer

#components
@onready var health_component: HealthComponent = $HealthComponent
@onready var input_movement: InputMovement = $InputMovement
@onready var state_machine: StateMachine = $StateMachine
@onready var mana_component: ManaComponent = $ManaComponent
@onready var upgrade_component: UpgradeComponent = $UpgradeComponent

var spell_controller: SpellController

const SPEED = 5.0
const SPELL_DRAW_TIME_LIMIT = 3 #sec
const JUMP_VELOCITY = 4.5
var mouse_sens = 0.3
var gravity = 20
var is_drawing_spell = false
var pitch := 0.0

var active_spell_driver: SpellDriver = null
var can_shoot_spell: bool = true

# ===== WALK BOB =====
var bob_time := 0.0
var bob_frequency := 1.0
var bob_amplitude := 0.04
var bob_side_amplitude := 0.04
var bob_smooth := 10.0

# ===== CAMERA TILT =====
var tilt_amount := 4.0 # degrees
var tilt_speed := 6.0
var current_tilt := 0.0

# ===== CAMERA EFFECTS =====
var _default_fov := 75.0
var _fov_tween: Tween
var _shake_tween: Tween
var _shake_offset := Vector3.ZERO
var _landing_bob_offset := 0.0
var _head_origin := Vector3.ZERO  # Stored on _ready to preserve original head position

# ===== HIT TRACKING =====
var _last_health: float = 150.0
var _is_dead := false

func _ready():
	health_component.set_max_health(150)
	health_component.set_health(150)
	health_component.destroy_on_death = false
	health_component.died.connect(_on_player_died)
	health_component.health_changed.connect(_on_health_changed)
	_last_health = 150.0

	spell_draw_limit_timer.timeout.connect(trigger_toggle_spell_mode)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	spell_controller = SpellController.new()
	spell_controller.set_basis_node(camera)
	spell_controller.set_spawn_node(pen_0)
	add_child(spell_controller)

	var hud_scene = load("res://scenes/ui/player_hud.tscn")
	var hud = hud_scene.instantiate()
	hud.setup(health_component, mana_component)
	add_child(hud)

	var upgrade_ui_scene = load("res://scenes/ui/upgrade_ui.tscn")
	var upgrade_ui = upgrade_ui_scene.instantiate()
	add_child(upgrade_ui)

	_default_fov = camera.fov
	_head_origin = head.position  # Store original head position (y=1.7)

func _process(delta):
	state_machine.update(delta)
	handle_spell_mode_toggle()

	# Smooth landing bob recovery
	if _landing_bob_offset != 0.0:
		_landing_bob_offset = lerp(_landing_bob_offset, 0.0, 8.0 * delta)
		if abs(_landing_bob_offset) < 0.001:
			_landing_bob_offset = 0.0

func _input(event):
	# Camera is still frozen during spell mode because of "and not is_drawing_spell"
	if event is InputEventMouseMotion and not is_drawing_spell:
		# Yaw (left/right)
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))

		# Pitch (up/down) — controlled manually
		pitch -= event.relative.y * mouse_sens
		pitch = clamp(pitch, -89.0, 89.0)

		head.rotation.x = deg_to_rad(pitch)

	if event.is_action_pressed("escape_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_drawing_spell:
			cast_active_spell()

	# Forward input to state machine for state-specific handling
	state_machine.handle_input(event)

func _clamp_mouse_to_canvas():
	var mouse_pos = get_viewport().get_mouse_position()
	var rect = drawing_container.get_global_rect()

	if not rect.has_point(mouse_pos):
		var clamped_x = clamp(mouse_pos.x, rect.position.x, rect.end.x - 1)
		var clamped_y = clamp(mouse_pos.y, rect.position.y, rect.end.y - 1)
		get_viewport().warp_mouse(Vector2(clamped_x, clamped_y))

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
	# Optional: keep grounded stable
		velocity.y = -1.0
	state_machine.physics_update(delta)

func _create_new_spell(spell_driver: SpellDriver):
	active_spell_driver = spell_driver
	cast_active_spell()

func cast_active_spell():
	if not active_spell_driver or not can_shoot_spell:
		return

	var cost = active_spell_driver._data.mana_cost if "mana_cost" in active_spell_driver._data else 10.0
	var r_time = active_spell_driver._data.reload_time if "reload_time" in active_spell_driver._data else 1.0

	if mana_component.spend(cost):
		Templates.save_spells()
		if active_spell_driver._data.name == "instant_dash":
			state_machine.change_state("DashState")
		else:
			spell_controller.create_spell(active_spell_driver)

		can_shoot_spell = false
		get_tree().create_timer(r_time).timeout.connect(func(): can_shoot_spell = true)
	else:
		print("Not enough mana!")

func execute_dash():
	# 1. Get WASD input (2D Vector)
	var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var dash_dir: Vector3

	if input_vec != Vector2.ZERO:
		var forward = -global_transform.basis.z
		var right = global_transform.basis.x
		dash_dir = (forward * -input_vec.y + right * input_vec.x).normalized()
	else:
		dash_dir = -global_transform.basis.z

	dash_dir.y = 0
	dash_dir = dash_dir.normalized()

	var dash_distance = 20.0
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, global_position + (dash_dir * dash_distance))

	var result = space_state.intersect_ray(query)
	var final_target = global_position + (dash_dir * dash_distance)

	if result:
		final_target = result.position - (dash_dir * 1.0)

	var duration = 0.2
	var tween = create_tween()
	tween.tween_property(self, "global_position", final_target, duration)\
		.set_trans(Tween.TRANS_QUINT)\
		.set_ease(Tween.EASE_OUT)

func handle_spell_mode_toggle():
	if Input.is_action_just_pressed("toggle_spell_mode") :
		is_drawing_spell = not is_drawing_spell
		if is_drawing_spell:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			spell_draw_limit_timer.start(SPELL_DRAW_TIME_LIMIT)

			if drawing_container:
				var rect = drawing_container.get_global_rect()
				var center_pos = rect.position + (rect.size / 2.0)
				get_viewport().warp_mouse(center_pos)

			state_machine.change_state("SpellState")
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			spell_draw_limit_timer.stop()
			# decide where to go
			var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
			if input_vec == Vector2.ZERO:
				state_machine.change_state("IdleState")
			else:
				state_machine.change_state("MoveState")

	if is_drawing_spell and drawing_container:
		_clamp_mouse_to_canvas()

# ============================================================
# VISUAL EFFECTS - Walk bob, Camera tilt, Shake, FOV, Landing
# ============================================================

func apply_walk_visuals(delta: float, intensity := 1.0) -> void:
	var vel = velocity
	var horizontal_speed = Vector2(vel.x, vel.z).length()

	# Normalize movement direction
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	# Speed factor (0 → 1)
	var speed_factor = clamp(horizontal_speed / input_movement.max_speed, 0, 1)

	# Advance bob time only if moving
	if speed_factor > 0.1:
		bob_time += delta * bob_frequency * (0.5 + speed_factor)
	else:
		bob_time = lerp(bob_time, 0.0, 4.0 * delta)  # Smooth decay instead of snap

	# STEP-BASED BOB
	var bob_y = abs(sin(bob_time)) * bob_amplitude * intensity * speed_factor
	var bob_forward = cos(bob_time) * 0.02 * speed_factor * intensity

	# SIDE SWAY (based on direction)
	var side = input.x
	var bob_x = sin(bob_time * 0.5) * bob_side_amplitude * side * intensity

	# Apply head bob as OFFSET from original position (not absolute)
	head.position.y = lerp(head.position.y, _head_origin.y + bob_y + _landing_bob_offset + _shake_offset.y, bob_smooth * delta)
	head.position.x = lerp(head.position.x, _head_origin.x + bob_x + _shake_offset.x, bob_smooth * delta)
	head.position.z = lerp(head.position.z, _head_origin.z + bob_forward + _shake_offset.z, bob_smooth * delta)

	# Pen motion (feels alive)
	pen_0.position.x = lerp(pen_0.position.x, -bob_x * 1.5, 12 * delta)
	pen_0.position.y = lerp(pen_0.position.y, -bob_y * 1.2, 12 * delta)

func apply_camera_tilt(delta: float) -> void:
	var input_x = Input.get_axis("move_left", "move_right")
	var mouse_tilt = Input.get_last_mouse_velocity().x * 0.01

	var target_tilt = -input_x * tilt_amount - mouse_tilt

	current_tilt = lerp(current_tilt, target_tilt, tilt_speed * delta)

	head.rotation.z = deg_to_rad(current_tilt)

# --- CAMERA SHAKE ---
func camera_shake(intensity: float = 0.1, duration: float = 0.2) -> void:
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()

	_shake_tween = create_tween()
	var steps := int(duration / 0.03)
	for i in steps:
		var offset = Vector3(
			randf_range(-intensity, intensity),
			randf_range(-intensity * 0.7, intensity * 0.7),
			randf_range(-intensity * 0.3, intensity * 0.3)
		)
		_shake_tween.tween_property(self, "_shake_offset", offset, 0.03)
	# Return to zero
	_shake_tween.tween_property(self, "_shake_offset", Vector3.ZERO, 0.06)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# --- FOV PUNCH (dash effect) ---
func camera_fov_punch(amount: float = 10.0, duration: float = 0.3) -> void:
	if _fov_tween and _fov_tween.is_valid():
		_fov_tween.kill()

	var punch_fov = _default_fov + amount
	_fov_tween = create_tween()
	_fov_tween.tween_property(camera, "fov", punch_fov, duration * 0.3)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	_fov_tween.tween_property(camera, "fov", _default_fov, duration * 0.7)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# --- CAMERA ZOOM (for spell mode etc.) ---
func camera_zoom(target_fov: float, duration: float = 0.4) -> void:
	if _fov_tween and _fov_tween.is_valid():
		_fov_tween.kill()

	_fov_tween = create_tween()
	_fov_tween.tween_property(camera, "fov", target_fov, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# --- LANDING BOB (camera dips on landing) ---
func landing_bob(amount: float = 0.05) -> void:
	_landing_bob_offset = -amount

# ============================================================
# DAMAGE / DEATH CALLBACKS
# ============================================================

func _on_health_changed(new_health: float, _max_health: float) -> void:
	if _is_dead:
		return

	# Trigger hit state when taking damage (not healing)
	if new_health < _last_health and new_health > 0:
		# Only stagger if not already in HitState, DashState, or DeathState
		var current = state_machine.current_state.name.validate_node_name() if state_machine.current_state else ""
		if current != "HitState" and current != "DashState" and current != "DeathState":
			state_machine.change_state("HitState")

	_last_health = new_health

func _on_player_died() -> void:
	if _is_dead:
		return
	_is_dead = true
	state_machine.change_state("DeathState")

func trigger_toggle_spell_mode():
	# 1. Create the event object
	var ev = InputEventAction.new()
	# 2. Set the action name (must match your Input Map exactly)
	ev.action = "toggle_spell_mode"
	# 3. Simulate the "Pressed" state
	ev.pressed = true
	Input.parse_input_event(ev)
	# 4. Simulate the "Released" state immediately
	# to prevent the action from being stuck "down"
	var release_ev = InputEventAction.new()
	release_ev.action = "toggle_spell_mode"
	release_ev.pressed = false
	Input.parse_input_event(release_ev)

func _exit_tree() -> void:
	Templates.save_spells()
