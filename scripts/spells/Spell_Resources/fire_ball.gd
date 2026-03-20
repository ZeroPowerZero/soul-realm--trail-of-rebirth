class_name FireBall
extends Area3D

@onready var throw_spell: ThrowSpell = $throw_spell

@export var life_time: float = 3
var _time: float

var _controller: SpellController

func _ready():
	global_position = _controller.basis_node.global_position
	global_basis = _controller.get_basis()
	
	throw_spell.change_owner(self)

func _physics_process(delta: float) -> void:
	throw_spell.move(delta)
	
	_time += delta
	if _time > life_time:
		queue_free()

func set_controller(who: SpellController):
	_controller = who
