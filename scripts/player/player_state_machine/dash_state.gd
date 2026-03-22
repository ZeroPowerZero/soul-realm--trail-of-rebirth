extends State

var timer = 0.2

func enter():
	timer = 0.2
	player.execute_dash()

func physics_update(delta):
	timer -= delta

	if timer <= 0:
		state_machine.change_state("IdleState")
