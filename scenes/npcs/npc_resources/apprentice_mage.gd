class_name ApprenticeMage
extends CharacterBody3D

@onready var area: Area3D = $Area3D
@onready var ai_movement: AiMovement = $AiMovement
@onready var health_component: HealthComponent = $HealthComponent

@export var state: NpcStateMachine.Npc_States = NpcStateMachine.Npc_States.IDLE
@export var random_point_timer: float = 5
@export var attack_stop_distance: float = 1.6

var spell_controller: SpellController

var _time: float
var _target: Node3D
var _in_npc_area: Array[Node3D]
var _in_self_area: Array[Node3D]

func _ready() -> void:
	health_component.set_health(health_component.get_max_health())
	spell_controller = SpellController.new()
	spell_controller.set_basis_node(self)
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
				if !_target.is_inside_tree():
					_remove_target(_target)
					_target = null
					if _in_self_area.is_empty() and _in_npc_area.is_empty():
						state = NpcStateMachine.Npc_States.IDLE
				else:
					var current_target_pos: Vector3 = _target.global_position
					var distance_to_target_sq: float = global_position.distance_squared_to(current_target_pos)
					if distance_to_target_sq > attack_stop_distance * attack_stop_distance:
						ai_movement.go_to(current_target_pos)
					else:
						ai_movement.stop()
			else:
				_target = _pick_next_target()

func go_random_points():
	var new_coord: Vector3 = global_position + Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
	ai_movement.go_to(new_coord)

func see_target(who: Node3D):
	state = NpcStateMachine.Npc_States.ATTACK
	if !_in_npc_area.has(who):
		_in_npc_area.append(who)
	if !_target:
		_target = who
func forget_target(who: Node3D):
	_remove_target(who)
	if _target == who:
		_target = _pick_next_target()

	if _in_self_area.is_empty() and _in_npc_area.is_empty():
		_target = null
		state = NpcStateMachine.Npc_States.IDLE

func _on_body_entered(body: Node3D):
	if body.is_in_group("Player"):
		state = NpcStateMachine.Npc_States.ATTACK
		if !_in_self_area.has(body):
			_in_self_area.append(body)
		if !_target:
			_target = body
func _on_body_exited(body: Node3D):
	if body.is_in_group("Player"):
		_remove_target(body)
		if _target == body:
			_target = _pick_next_target()

		if _in_self_area.is_empty() and _in_npc_area.is_empty():
			_target = null
			state = NpcStateMachine.Npc_States.IDLE
			ai_movement.stop()

func _pick_next_target() -> Node3D:
	var candidates: Array[Node3D] = []
	for body in _in_self_area:
		if body and body.is_inside_tree():
			candidates.append(body)
	for body in _in_npc_area:
		if body and body.is_inside_tree() and !candidates.has(body):
			candidates.append(body)
	return candidates.pick_random() if !candidates.is_empty() else null

func _remove_target(who: Node3D) -> void:
	if _in_self_area.has(who):
		_in_self_area.erase(who)
	if _in_npc_area.has(who):
		_in_npc_area.erase(who)
