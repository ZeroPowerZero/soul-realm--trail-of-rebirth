extends SubViewportContainer

@onready var drawing: Line2D = $SubViewport/Drawing
@onready var fire_button: Button = $"../../FireControl/FireButton"
# ====== ACTIVE RESOURCES ======
var selected_spell_resource:SpellDriver = null;
var castes_before_reset:int = 0
# ====== SIGNALS ======
signal pen_moved(canvas_pos: Vector2, canvas_size: Vector2)
signal drawing_state_changed(is_drawing: bool)
signal create_new_spell(spell_driver: SpellDriver)

# ====== CONFIGURATION ======
const NUM_POINTS: int = 64            # Number of points after resampling
const SQUARE_SIZE: float = 250.0      # Normalized bounding size
const MIN_POINT_DISTANCE: float = 4.0 # Minimum distance before adding new stroke point
const LINE_INTERPOLATION_STEP: float = 6.0

var stroke_points: Array[Vector2] = []
var is_drawing: bool = false

@export var is_recording_mode: bool = false
@export var spell_resource_to_record: SpellData

# ==========================================================
# INPUT SYSTEM (Event Driven)
# ==========================================================
func _gui_input(event: InputEvent) -> void:
	# Bounded to holding a specific button (map "draw_spell" in Input Map)
	if event.is_action("draw_spell"):
		if event.is_pressed() and not is_drawing:
			# Safety check to ensure the event has a position property
			if event is InputEventMouse or event is InputEventScreenTouch:
				_start_stroke(event.position)
				
		elif event.is_released() and is_drawing:
			_end_stroke()
	
	# Mouse moved while pressed → continue stroke and move 3D pen
	if event is InputEventMouseMotion and is_drawing:
		_update_stroke(event.position)
		pen_moved.emit(event.position, size)

# ==========================================================
# STROKE CONTROL
# ==========================================================
func _start_stroke(pos: Vector2) -> void:
	is_drawing = true
	drawing_state_changed.emit(true)
	
	stroke_points.clear()
	drawing.clear_points()
	
	stroke_points.append(pos)
	drawing.add_point(pos)
	pen_moved.emit(pos, size)

func _update_stroke(pos: Vector2) -> void:
	var last_point = stroke_points.back()
	
	# Interpolate to avoid gaps if moving too fast
	if last_point.distance_to(pos) > LINE_INTERPOLATION_STEP:
		_add_point(pos)

func _end_stroke() -> void:
	is_drawing = false
	drawing_state_changed.emit(false)
	
	if stroke_points.size() > 10:
		var normalized_gesture = _process_stroke(stroke_points)
		_handle_gesture_result(normalized_gesture)
	
	await get_tree().create_timer(0.5).timeout
	
	if not is_drawing:
		drawing.clear_points()
		stroke_points.clear()

###################### LOGIC HERE #####################################
func _handle_gesture_result(normalized_gesture: Array[Vector2]) -> void:
	if is_recording_mode:
		# Save it automatically to the Templates Autoload
		Templates.save_new_spell(spell_resource_to_record, normalized_gesture)
	else:
		var recognized_spell = Templates.recognize_spell(normalized_gesture)
		
		if recognized_spell != null:
			fire_button.text = "Caste : " + recognized_spell.get_data().name + " "+ str(recognized_spell.get_level()) 
			selected_spell_resource = recognized_spell
			castes_before_reset = recognized_spell.get_level();
			trigger_toggle_spell_mode()
		else:
			fire_button.text = "Caste Failed"	
#################################################################
func trigger_toggle_spell_mode():
	# 1. Create the event object
	var ev = InputEventAction.new()
	# 2. Set the action name (must match your Input Map exactly)
	ev.action = "toggle_spell_mode"
	# 3. Simulate the "Pressed" state
	ev.pressed = true
	Input.parse_input_event(ev)
	# 4. Simulate the "Released" state immediately 
	# to prevent the action from being stuck "down"
	var release_ev = InputEventAction.new()
	release_ev.action = "toggle_spell_mode"
	release_ev.pressed = false
	Input.parse_input_event(release_ev)

# ==========================================================
# DRAWING HELPERS
# ==========================================================
func _add_point(pos: Vector2) -> void:
	if stroke_points.is_empty() or stroke_points.back().distance_to(pos) > MIN_POINT_DISTANCE:
		stroke_points.append(pos)
		drawing.add_point(pos)

# ==========================================================
# GESTURE NORMALIZATION PIPELINE
# ==========================================================
func _process_stroke(points: Array[Vector2]) -> Array[Vector2]:
	var resampled = _resample(points, NUM_POINTS)
	var centered = _translate_to_origin(resampled)
	var scaled = _scale_to_square(centered, SQUARE_SIZE)
	return scaled

func _resample(points: Array[Vector2], n: int) -> Array[Vector2]:
	if points.size() < 2:
		return points.duplicate()
	
	var total_length = _path_length(points)
	var interval = total_length / (n - 1)
	
	if interval <= 0.001:
		return _duplicate_points(points[0], n)
	
	var D: float = 0.0
	var new_points: Array[Vector2] = [points[0]]
	var working = points.duplicate()
	var i: int = 1
	
	while i < working.size():
		var d = working[i - 1].distance_to(working[i])
		if D + d >= interval:
			var ratio = (interval - D) / d if d > 0 else 0.0
			var new_point = working[i - 1].lerp(working[i], ratio)
			new_points.append(new_point)
			working.insert(i, new_point)
			D = 0.0
			i += 1 
		else:
			D += d
			i += 1
	while new_points.size() < n:
		new_points.append(working.back())
	return new_points
func _duplicate_points(point: Vector2, n: int) -> Array[Vector2]:
	var arr: Array[Vector2] = []
	for i in range(n):
		arr.append(point)
	return arr

func _path_length(points: Array[Vector2]) -> float:
	var length: float = 0.0
	for i in range(1, points.size()):
		length += points[i - 1].distance_to(points[i])
	return length

func _translate_to_origin(points: Array[Vector2]) -> Array[Vector2]:
	var centroid = Vector2.ZERO
	for p in points:
		centroid += p
	centroid /= points.size()
	
	var new_points: Array[Vector2] = []
	for p in points:
		new_points.append(p - centroid)
	return new_points

func _scale_to_square(points: Array[Vector2], _size: float) -> Array[Vector2]:
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	
	for p in points:
		min_x = min(min_x, p.x)
		max_x = max(max_x, p.x)
		min_y = min(min_y, p.y)
		max_y = max(max_y, p.y)
	
	var width = max_x - min_x
	var height = max_y - min_y
	var _scale = _size / max(width, height) if max(width, height) != 0 else 1.0
	
	var new_points: Array[Vector2] = []
	for p in points:
		new_points.append(p * _scale)
	return new_points


func _on_fire_button_pressed() -> void:
	if selected_spell_resource != null and castes_before_reset != 0:
		create_new_spell.emit(selected_spell_resource)
		castes_before_reset-=1
		if castes_before_reset == 0 :
			selected_spell_resource = null
			fire_button.text = "Re Draw to Caste"
