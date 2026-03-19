extends Area3D

@onready var anim_player = $AnimationPlayer 

@export var damage: int = 20
@export var life_time: float = 4.0
var _time: float

var _controller: SpellController

func _ready() -> void:
	global_position = _controller.basis_node.global_position-Vector3.UP
	var new_euler = _controller.get_basis()*Vector3.ONE
	var rot = atan2(-new_euler.z, new_euler.x)
	var new_quat = Quaternion.from_euler(Vector3(0, rot+0.75, 0))
	global_basis = Basis(new_quat.normalized())
	
	anim_player.play("init")

func set_controller(who: SpellController):
	_controller = who

func _process(delta: float) -> void:
	_time += delta
	
	if _time > life_time:
		queue_free()
