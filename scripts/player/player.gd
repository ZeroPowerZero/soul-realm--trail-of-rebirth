class_name Player
extends CharacterBody3D

@onready var head: Node3D = $head
@onready var drawing_container: Control = $DrawingCanvas/MarginContainer/SubViewportContainer
@onready var camera: Camera3D = $head/Camera3D
@onready var pen_0: Node3D = $head/Camera3D/view_model/Pen_0

#components
@onready var health_component: HealthComponent = $HealthComponent
@onready var input_movement: InputMovement = $InputMovement
@onready var state_machine: StateMachine = $StateMachine

var spell_controller: SpellController

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var mouse_sens = 0.3

var is_drawing_spell = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	spell_controller = SpellController.new()
	spell_controller.set_basis_node(camera)
	spell_controller.set_spawn_node(pen_0)
	add_child(spell_controller)

func _process(delta):
	state_machine.update(delta)
	handle_spell_mode_toggle()

func _input(event):
	# Camera is still frozen during spell mode because of "and not is_drawing_spell"
	if event is InputEventMouseMotion and not is_drawing_spell:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	if event.is_action_pressed("escape_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _clamp_mouse_to_canvas():
	var mouse_pos = get_viewport().get_mouse_position()
	var rect = drawing_container.get_global_rect()
	
	if not rect.has_point(mouse_pos):
		var clamped_x = clamp(mouse_pos.x, rect.position.x, rect.end.x - 1)
		var clamped_y = clamp(mouse_pos.y, rect.position.y, rect.end.y - 1)
		get_viewport().warp_mouse(Vector2(clamped_x, clamped_y))

func _physics_process(delta: float) -> void:
	state_machine.physics_update(delta)

func _create_new_spell(spell_driver: SpellDriver):
	if spell_driver._data.name == "instant_dash":
		state_machine.change_state("DashState")
	else:
		spell_controller.create_spell(spell_driver)

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
		
	print("Dashing to: ", final_target)

func handle_spell_mode_toggle():
	if Input.is_action_just_pressed("toggle_spell_mode"):
		is_drawing_spell = not is_drawing_spell
		
		if is_drawing_spell:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
			if drawing_container:
				var rect = drawing_container.get_global_rect()
				var center_pos = rect.position + (rect.size / 2.0)
				get_viewport().warp_mouse(center_pos)
				
			state_machine.change_state("SpellState")
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
			# decide where to go
			var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
			if input_vec == Vector2.ZERO:
				state_machine.change_state("IdleState")
			else:
				state_machine.change_state("MoveState")

	if is_drawing_spell and drawing_container:
		_clamp_mouse_to_canvas()
