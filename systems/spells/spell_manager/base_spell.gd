class_name BaseSpell
extends Node3D

var _controller: SpellController
var _driver: SpellDriver

func set_controller(who: SpellController):
	_controller = who

func set_driver(d: SpellDriver, is_extra := false):
	_driver = d

func _ready() -> void:
	if _controller:
		global_position = _controller.get_spawn_position()
		var dir = _controller.get_forward_direction()
		# Only look_at if valid forward direction
		if dir.length() > 0.1 and abs(dir.dot(Vector3.UP)) < 0.999:
			look_at(global_position + dir, Vector3.UP)
