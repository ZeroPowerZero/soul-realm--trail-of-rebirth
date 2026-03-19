extends Area3D

@onready var throw_spell: ThrowSpell = $throw_spell

@export var life_time: float = 3
var _time: float

var _controller: SpellController

func _ready():
	global_position = _controller.get_spawn_position()
	
	var dir = _controller.get_forward_direction()
	look_at(global_position + dir, Vector3.UP)
	
	throw_spell.change_owner(self)

func _physics_process(delta: float) -> void:
	throw_spell.move(delta)
	
	_time += delta
	if _time > life_time:
		queue_free()

func set_controller(who: SpellController):
	_controller = who
