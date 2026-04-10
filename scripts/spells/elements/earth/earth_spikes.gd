extends Area3D

@onready var anim_player = $AnimationPlayer 

@export var damage: int = 20
@export var life_time: float = 4.0

var _time: float
var _controller: SpellController
var _driver : SpellDriver

func _ready() -> void:
	global_position = _controller.basis_node.global_position-Vector3.UP
	var new_euler = _controller.get_basis()*Vector3.FORWARD
	var rot = atan2(-new_euler.x, -new_euler.z)
	var new_quat = Quaternion.from_euler(Vector3(0, rot, 0))
	global_basis = Basis(new_quat.normalized())
	
	anim_player.play("init")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	var caster = _controller
	var is_caster_enemy = caster and caster.is_in_group("Enemy")
	var is_caster_player = caster and caster.is_in_group("Player")
	
	if is_caster_enemy and body.is_in_group("Enemy"):
		return
	if is_caster_player and body.is_in_group("Player"):
		return
		
	if body.is_in_group("Enemy") or body.is_in_group("Player"):
		var damage_amount = _driver.get_damage() if (_driver and _driver.has_method("get_damage")) else damage
		if body.get("health_component") and body.health_component.has_method("take_damage"):
			body.health_component.take_damage(damage_amount)

func set_controller(who: SpellController):
	_controller = who

func set_driver(d : SpellDriver, _is_extra := false):
	_driver = d

func _process(delta: float) -> void:
	_time += delta
	
	if _time > life_time:
		queue_free()
