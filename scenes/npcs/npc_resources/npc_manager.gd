class_name NPCMANAGER
extends Resource

var _resource: NPC_RESOURCE

var _current_state: NpcStateMachine.states = 0 as NpcStateMachine.states
var _level: int = 1

func _init(resource: NPC_RESOURCE, level: int = 1):
	_resource = resource
	_level = level

# SETTER FUNCTIONS
func set_state(new_state: NpcStateMachine.states) -> void:
	_current_state = new_state
func set_resource(new_resource: NPC_RESOURCE) -> void:
	_resource = new_resource

# GETTER FUNCTIONS
func get_state() -> NpcStateMachine.states:
	return _current_state
func get_resource() -> NPC_RESOURCE:
	return _resource
