extends Area3D

@export var damage: int = 20
@export var life_time: float = 4.0

# Grab the animation player
@onready var anim_player = $AnimationPlayer 

var _controller: SpellController

func _ready() -> void:
	if anim_player.has_animation("init"):
		anim_player.play("init")
	
	# 2. Start the timer to delete the spell
	start_despawn_timer()

func set_controller(who: SpellController):
	_controller = who

func start_despawn_timer():
	await get_tree().create_timer(life_time).timeout
	queue_free()
