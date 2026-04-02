class_name EnemyDrawVisualizer
extends Node3D

var viewport: SubViewport
var bg_rect: ColorRect
var line: Line2D
var sprite: Sprite3D

@export var target_sprite: Sprite3D
@export var draw_color: Color = Color(1.0, 0.4, 0.0, 1.0)
@export var draw_thickness: float = 12.0

var _target_points: Array[Vector2] = []
var _draw_duration: float = 1.0
var _draw_time_elapsed: float = 0.0
var _drawn_points_count: int = 0
var _is_drawing: bool = false

func _ready() -> void:
	viewport = SubViewport.new()
	viewport.size = Vector2(512, 512)
	viewport.transparent_bg = true
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS 
	add_child(viewport)
	
	bg_rect = ColorRect.new()
	bg_rect.size = Vector2(512, 512)
	bg_rect.color = Color(0.0, 0.0, 0.0, 0.4) # Dark translucent window
	bg_rect.hide()
	viewport.add_child(bg_rect)
	
	line = Line2D.new()
	line.width = draw_thickness
	line.default_color = draw_color
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.modulate = Color(1.5, 1.5, 1.5, 1.0)
	viewport.add_child(line)
	
	if target_sprite:
		target_sprite.texture = viewport.get_texture()
	else:
		sprite = Sprite3D.new()
		sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		sprite.texture = viewport.get_texture()
		sprite.transparent = true
		sprite.shaded = false
		sprite.double_sided = true
		sprite.pixel_size = 0.005
		sprite.position = Vector3(0, 3.0, 0)
		add_child(sprite)
		target_sprite = sprite

func start_drawing(points: Array[Vector2], duration: float) -> void:
	line.clear_points()
	_target_points = points
	_draw_duration = duration
	_draw_time_elapsed = 0.0
	_drawn_points_count = 0
	_is_drawing = true
	bg_rect.show()
	
	if points.size() > 0:
		line.add_point(points[0] + Vector2(256, 256))
		_drawn_points_count = 1

func _process(delta: float) -> void:
	if not _is_drawing or _target_points.size() == 0:
		return
		
	_draw_time_elapsed += delta
	var progress = _draw_time_elapsed / _draw_duration
	progress = clamp(progress, 0.0, 1.0)
	
	var target_count = int(progress * _target_points.size())
	while _drawn_points_count < target_count and _drawn_points_count < _target_points.size():
		var p = _target_points[_drawn_points_count] + Vector2(256, 256)
		line.add_point(p)
		_drawn_points_count += 1
		
	if progress >= 1.0:
		_is_drawing = false

func set_color(c: Color):
	draw_color = c
	if is_instance_valid(line):
		line.default_color = c

func clear_drawing():
	line.clear_points()
	_is_drawing = false
	bg_rect.hide()
