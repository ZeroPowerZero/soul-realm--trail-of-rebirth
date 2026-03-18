class_name NPCMANAGER
extends Resource

@export var _resource: NPC_RESOURCE

@export var _current_state: NpcStateMachine.Npc_States = NpcStateMachine.Npc_States.IDLE

@export var _max_speed: float = 3
@export var _acceleration: float = 3
@export var _friction: float = 7

func _init(_new_resource: NPC_RESOURCE = null) -> void:
	if _new_resource:
		set_resource_with_default_values(_new_resource)

# SETTER FUNCTIONS
func set_resource_with_default_values(_new_resource: NPC_RESOURCE = _resource) -> void:
	set_resource(_new_resource)
	set_max_speed(_new_resource.default_max_speed)
	set_acceleration(_new_resource.default_acceleration)
	set_friction(_new_resource.default_friction)
func set_state(new_state: NpcStateMachine.Npc_States) -> void:
	_current_state = new_state
func set_resource(new_resource: NPC_RESOURCE) -> void:
	_resource = new_resource
func set_max_speed(new_max_speed: float):
	_max_speed = new_max_speed
func set_acceleration(new_acceleration: float):
	_acceleration = new_acceleration
func set_friction(new_friction: float):
	_friction = new_friction
# GETTER FUNCTIONS
func get_state() -> NpcStateMachine.Npc_States:
	return _current_state
func get_resource() -> NPC_RESOURCE:
	return _resource
func get_max_speed() -> float:
	return _max_speed
func get_acceleration() -> float:
	return _acceleration
func get_friction() -> float:
	return _friction
