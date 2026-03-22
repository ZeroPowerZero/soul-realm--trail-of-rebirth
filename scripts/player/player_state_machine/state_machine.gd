class_name StateMachine
extends State

@onready var current_state: State
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.state_machine = self
		else:
			push_warning("problem in state machine containing shit")

	change_state("IdleState")

func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

#func physics_update(delta):
	#if current_state:
		#current_state.physics_update(delta)

func change_state(new_state_name: String):
	var new_state = states.get(new_state_name)

	if new_state == null:
		push_error("State not found: " + new_state_name)
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()
