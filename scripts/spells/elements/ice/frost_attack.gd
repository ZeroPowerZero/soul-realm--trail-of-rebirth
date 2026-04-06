class_name FrostAttack
extends Area3D

var _controller: Node # SpellController
var _driver: SpellDriver # SpellDriver

var _level: int = 1
var _active_duration: float = 0.5 
var _time: float = 0.0

func set_controller(who):
	_controller = who

func set_driver(d, _is_extra := false):
	_driver = d

func _ready() -> void:
	if _controller:
		global_position = _controller.get_spawn_position()
	
	if _driver and _driver.has_method("get_level"):
		_level = _driver.get_level()
		
	setup_roguelike_level()
	body_entered.connect(_on_body_entered)

func setup_roguelike_level():
	print("--- Setup Frost Nova Level ", _level, " ---")
	
	if _level >= 1:
		print("[Lvl 1] Standard Frost Nova: Emits freezing wave slowing enemies by 50%.")
		
	if _level >= 2:
		print("[Lvl 2] Deep Freeze: Enemies are completely frozen for 1.5 seconds instead of slowed.")
		
	if _level >= 3:
		print("[Lvl 3] Expanded Radius: Nova range is doubled!")
		# Here you would: scale = Vector3(2, 2, 2)
		
	if _level >= 4:
		print("[Lvl 4] Brittle Effect: Frozen enemies take 50% more damage from all sources.")
		
	if _level >= 5:
		print("[Lvl 5] Shatter: Upon thawing or death, enemies explode with ice shards.")

func _physics_process(delta: float) -> void:
	_time += delta
	if _time > _active_duration:
		# Effect has lingered long enough to hit everyone in range
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	var caster = _controller.get_basis_node() if _controller and _controller.has_method("get_basis_node") else null
	var is_caster_enemy = caster and caster.is_in_group("Enemy")
	
	# Prevent friendly fire
	if is_caster_enemy and body.is_in_group("Enemy"):
		return
	if not is_caster_enemy and body.is_in_group("Player"):
		return
		
	apply_frost_effect(body)

func apply_frost_effect(body: Node3D):
	if not is_instance_valid(body):
		return
		
	print("Frost Nova hit ", body.name, "!")
	
	if _level >= 2:
		print("Applying DEEP FREEZE to ", body.name)
		# E.g. body.is_frozen = true
		# timer.start(1.5)
	else:
		print("Applying 50% SLOW to ", body.name)
		# E.g. body.movement_speed *= 0.5
		
	if _level >= 4:
		print("Applying BRITTLE debuff to ", body.name)
		
	if _level >= 5:
		print("Queuing SHATTER hook on ", body.name)
