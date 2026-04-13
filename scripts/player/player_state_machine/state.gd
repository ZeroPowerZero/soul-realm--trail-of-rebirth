class_name State
extends Node

## Base class for all player states.
## Player and state_machine references are injected by StateMachine on _ready().

var player: Player
var state_machine: StateMachine

# Called when this state becomes the active state
func enter() -> void:
	pass

# Called when this state is being replaced by another state
func exit() -> void:
	pass

# Called every frame (from player _process)
func update(_delta: float) -> void:
	pass

# Called every physics frame (from player _physics_process)
func physics_update(_delta: float) -> void:
	pass

# Called to route input events into the active state
func handle_input(_event: InputEvent) -> void:
	pass
