extends Area3D

@export var life_time: float = 3
var _time: float

@onready var throw_spell: ThrowSpell = $throw_spell

var _controller: SpellController

func _ready() -> void:
	var new_basis = _controller.get_basis()
	basis = new_basis
	
	throw_spell.change_owner(self)

func _physics_process(delta: float) -> void:
	throw_spell.move(delta)
	
	_time += delta
	if _time > life_time:
		queue_free()

func set_controller(who: SpellController):
	_controller = who
