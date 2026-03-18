extends Area3D

@export var damage: int = 20
@export var life_time: float = 4.0

var _controller: SpellController

func _ready() -> void:
	# Start the 4-second timer immediately
	start_despawn_timer()

func set_controller(who: SpellController):
	_controller = who

func start_despawn_timer():
	await get_tree().create_timer(life_time).timeout
	queue_free()
