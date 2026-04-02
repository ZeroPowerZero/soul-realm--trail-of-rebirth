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
	if is_drawing and not is_casting:
		# If the player gets greedy and draws, quickly stop and prepare a fast interrupt counter
		velocity = Vector3.ZERO
		prepare_and_cast_spell(counter_spell_name, 0.4) # Fast 0.4s cast

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target_player):
		target_player = find_player()
		return

	if is_casting:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	var dist = global_position.distance_to(target_player.global_position)
	var dir = (target_player.global_position - global_position).normalized()
	dir.y = 0
	
	if dist > attack_range:
		velocity = dir * movement_speed
	elif dist < attack_range - 5.0:
		# Counter mage is squishy, tries to back away if player gets too close
		velocity = -dir * (movement_speed * 0.8) 
	else:
		velocity = Vector3.ZERO
		
	var look_pos = target_player.global_position
	look_pos.y = global_position.y
	look_at(look_pos, Vector3.UP)
	
	move_and_slide()
