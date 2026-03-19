class_name ApprenticeMage
extends CharacterBody3D

@onready var area: Area3D = $Area3D

@export var state: NpcStateMachine.Npc_States = NpcStateMachine.Npc_States.IDLE
@export var random_point_timer: float = 5
@export var ai_movement_settings: AIMOVEMENTSETTINGS
@export var health_component_settings: HealthComponentSettings

var ai_movement: AIMOVEMENT
var health_component: HealthComponent
var spell_controller: SpellController

var _time: float
var _target: Node3D
var _in_npc_area: Array[Node3D]
var _in_self_area: Array[Node3D]

func _ready() -> void:
	spell_controller = SpellController.new()
	ai_movement = AIMOVEMENT.new()
	health_component = HealthComponent.new()
	spell_controller.set_basis_node(self)
	ai_movement.set_settings(ai_movement_settings)
	health_component.set_settings(health_component_settings)
	add_child(ai_movement)
	add_child(health_component)
	add_child(spell_controller)
	
	area.connect("body_entered", _on_body_entered)
	area.connect("body_exited", _on_body_exited)

var random_effect: float = randf_range(-3, 3)
func _process(delta: float) -> void:
	match state:
		NpcStateMachine.Npc_States.IDLE:
			_time += delta
			
			if _time > random_point_timer+random_effect:
				random_effect = randf_range(-3, 3)
				go_random_points()
				_time = 0
		NpcStateMachine.Npc_States.ATTACK:
			if _target:
				ai_movement.go_to(_target.position)
			else:
				_target = (_in_self_area + _in_npc_area).pick_random()

func go_random_points():
	var new_coord: Vector3 = Vector3(randf_range(-5, 5), position.y, randf_range(-5, 5))
	ai_movement.go_to(new_coord)

func see_target(who: Node3D):
	state = NpcStateMachine.Npc_States.ATTACK
	_in_npc_area.append(who)
func forget_target(who: Node3D):
	if _in_npc_area.has(who):
		_in_npc_area.erase(who)
		
		if _in_self_area.is_empty() and _in_npc_area.is_empty():
			_target = null
			state = NpcStateMachine.Npc_States.IDLE

func _on_body_entered(body: Node3D):
	if body.is_in_group("Player"):
		state = NpcStateMachine.Npc_States.ATTACK
		_in_self_area.append(body)
func _on_body_exited(body: Node3D):
	if body.is_in_group("Player") and _in_self_area.has(body):
		_in_self_area.erase(body)
		
		if _in_self_area.is_empty() and _in_npc_area.is_empty():
			_target = null
			state = NpcStateMachine.Npc_States.IDLE
