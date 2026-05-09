class_name StateMachine
extends Node

## Professional state machine that manages player states.
## Extends Node (not State) — it orchestrates states, it IS NOT a state.

signal state_changed(old_state_name: String, new_state_name: String)

@onready var current_state: State
var states: Dictionary = {}
var previous_state: State
var player: Player

func _ready():
	player = get_parent() as Player
	if not player:
		push_error("StateMachine must be a child of Player!")
		return

	for child in get_children():
		if child is State:
			states[child.name] = child
			child.state_machine = self
			child.player = player
		else:
			push_warning("StateMachine child '%s' is not a State node." % child.name)

	change_state("IdleState")

# Forward frame update to active state
func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)

# Forward physics update to active state
func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

# Forward input events to active state
func handle_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

# Transition to a new state by node name
func change_state(new_state_name: String) -> void:
	var new_state = states.get(new_state_name)

	if new_state == null:
		push_error("State not found: " + new_state_name)
		return

	if current_state == new_state:
		return  # Already in this state, skip redundant transition

	if current_state:
		current_state.exit()
		previous_state = current_state

	var old_name = current_state.name.validate_node_name() if current_state else ""
	current_state = new_state
	current_state.enter()

	state_changed.emit(old_name, new_state_name)
	

# Returns the name of the previous state (useful for "return to what I was doing")
func get_previous_state_name() -> String:
	if previous_state:
		return previous_state.name
	return "IdleState"
