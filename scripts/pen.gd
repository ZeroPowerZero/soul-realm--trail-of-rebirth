extends Node3D

@export var spell_billboard: Sprite3D 
@export var tracking_speed: float = 25.0 

# The distance to hover the pen slightly in front of the Sprite3D so it doesn't clip inside it
@export var z_offset: float = 0.05 

var is_currently_drawing: bool = false
var current_surface_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	if spell_billboard:
		global_position = spell_billboard.global_position

func _process(delta: float) -> void:
	if not spell_billboard:
		return
		
	# 1. Get the exact direction the rotating Sprite3D is facing right now
	var right_vector = spell_billboard.global_transform.basis.x.normalized()
	var up_vector = spell_billboard.global_transform.basis.y.normalized()
	var forward_vector = spell_billboard.global_transform.basis.z.normalized()
	
	# 2. Mathematically project our 2D drawing onto the 3D surface
	# We start at the center of the billboard, move along its X axis, move along its Y axis, 
	# and pop it out slightly along its Z axis.
	var target_global_pos = spell_billboard.global_position \
		+ (right_vector * current_surface_offset.x) \
		+ (up_vector * current_surface_offset.y) \
		+ (forward_vector * z_offset)
	
	# 3. Smoothly move the pen to that global point
	if is_currently_drawing:
		global_position = global_position.lerp(target_global_pos, tracking_speed * delta)
	else:
		# When not drawing, neatly return to the center of the billboard
		var center_pos = spell_billboard.global_position + (forward_vector * z_offset)
		global_position = global_position.lerp(center_pos, tracking_speed * delta)

# ==========================================
# SIGNAL RECEIVERS
# ==========================================

func _on_spell_drawing_controller_pen_moved(canvas_pos: Vector2, canvas_size: Vector2) -> void:
	if not spell_billboard:
		return
		
	# Normalize from 0.0 to 1.0
	var normalized_x = canvas_pos.x / canvas_size.x
	var normalized_y = canvas_pos.y / canvas_size.y
	
	# Shift origin to center (-0.5 to 0.5)
	var centered_x = normalized_x - 0.5
	var centered_y = normalized_y - 0.5
	
	# Calculate physical size based on the Sprite3D's pixel scale
	var physical_width = canvas_size.x * spell_billboard.pixel_size
	var physical_height = canvas_size.y * spell_billboard.pixel_size
	
	# Store the offset. Invert Y because 3D Y goes up, 2D Y goes down.
	current_surface_offset.x = centered_x * physical_width
	current_surface_offset.y = -centered_y * physical_height

func _on_spell_drawing_controller_drawing_state_changed(is_drawing: bool) -> void:
	is_currently_drawing = is_drawing
	
	if not is_drawing:
		current_surface_offset = Vector2.ZERO
