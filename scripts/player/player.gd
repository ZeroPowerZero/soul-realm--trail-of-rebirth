extends CharacterBody3D

@onready var head = $head
@onready var drawing_container: Control = $DrawingCanvas/MarginContainer/SubViewportContainer
@onready var camera: Camera3D = $head/Camera3D
@onready var pen_0: Node3D = $head/Camera3D/view_model/Pen_0

@export var health_component_settings: HealthComponentSettings

var health_component: HealthComponent
var spell_controller: SpellController

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var mouse_sens = 0.3

var is_drawing_spell = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	spell_controller = SpellController.new()
	health_component = HealthComponent.new()
	spell_controller.set_basis_node(camera)
	health_component.set_settings(health_component_settings)
	add_child(spell_controller)

func _process(_delta):
	if Input.is_action_just_pressed("toggle_spell_mode"):
		is_drawing_spell = not is_drawing_spell
		
		if is_drawing_spell:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if drawing_container:
				var rect = drawing_container.get_global_rect()
				var center_pos = rect.position + (rect.size / 2.0)
				get_viewport().warp_mouse(center_pos)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if is_drawing_spell and drawing_container:
		_clamp_mouse_to_canvas()

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
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Removed the spell check here so you can jump while drawing
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

func _create_new_spell(spell_driver: SpellDriver):
	spell_controller.create_spell(spell_driver)
