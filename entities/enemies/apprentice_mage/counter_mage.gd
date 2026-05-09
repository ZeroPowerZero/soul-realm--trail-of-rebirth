class_name CounterMage
extends MageBase

@export var counter_spell_name: String = "Push Back"
var drawing_canvas: Node = null

func _ready() -> void:
	super._ready()
	call_deferred("_find_canvas")

func _find_canvas():
	var controllers = get_tree().get_nodes_in_group("SpellCanvas")
	if controllers.size() > 0:
		drawing_canvas = controllers[0]
	else:
		# Search the tree for the node that has the drawing signal
		drawing_canvas = _find_node_with_signal(get_tree().root, "drawing_state_changed")
	
	if drawing_canvas:
		# Use Callables for Godot 4
		drawing_canvas.drawing_state_changed.connect(_on_player_drawing_changed)
	else:
		push_warning("CounterMage: Could not find SpellDrawingController to connect to!")

func _find_node_with_signal(node: Node, sig_name: String) -> Node:
	if node.has_signal(sig_name):
		return node
	for child in node.get_children():
		var found = _find_node_with_signal(child, sig_name)
		if found:
			return found
	return null

func _on_player_drawing_changed(is_drawing: bool):
	if is_drawing and not is_casting and has_line_of_sight(target_player):
		# If the player gets greedy and draws, quickly stop and prepare a fast interrupt counter
		velocity.x = 0
		velocity.z = 0
		prepare_and_cast_spell(counter_spell_name, 0.4) # Fast 0.4s cast

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	if not is_instance_valid(target_player):
		target_player = find_player()
		if not is_on_floor():
			move_and_slide()
		return

	if is_casting:
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return

	nav_agent.target_position = target_player.global_position
	var dist = global_position.distance_to(target_player.global_position)
	var has_los = has_line_of_sight(target_player)
	
	if dist > attack_range or not has_los:
		# Move towards player using pathfinding
		var next_location = nav_agent.get_next_path_position()
		var dir = (next_location - global_position).normalized()
		dir.y = 0
		if dir.length_squared() > 0.001:
			velocity.x = dir.x * movement_speed
			velocity.z = dir.z * movement_speed
		else:
			velocity.x = 0
			velocity.z = 0
	elif dist < attack_range - 5.0:
		# Counter mage is squishy, tries to back away if player gets too close
		var dir = (global_position - target_player.global_position).normalized()
		dir.y = 0
		velocity.x = dir.x * (movement_speed * 0.8)
		velocity.z = dir.z * (movement_speed * 0.8)
	else:
		velocity.x = 0
		velocity.z = 0
		
	var look_pos = target_player.global_position
	look_pos.y = global_position.y
	look_at(look_pos, Vector3.UP)
	
	move_and_slide()
