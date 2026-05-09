class_name Flames
extends Area3D

var _controller: Node # SpellController
var _driver: SpellDriver # SpellDriver

var _level: int = 1
var _duration: float = 2.0
var _tick_rate: float = 0.5
var _tick_timer: float = 0.0

# Store overlapping bodies to damage them over time
var _victims: Array = []

func set_controller(who):
	_controller = who

func set_driver(d: SpellDriver, _is_extra := false):
	_driver = d

func _ready() -> void:
	if _driver and _driver.has_method("get_level"):
		_level = _driver.get_level()
		
	setup_roguelike_level()

	var end_timer = get_tree().create_timer(_duration)
	end_timer.timeout.connect(queue_free)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func setup_roguelike_level():
	print("--- Setup Flames Level ", _level, " ---")
	
	if _level >= 1:
		_duration = 2.0
		print("[Lvl 1] Basic 2.0s continuous flame attack.")
		
	if _level >= 2:
		_duration = 3.5
		print("[Lvl 2] Flames duration extended to 3.5 seconds. Wider area.")
		# Note: You would scale up the CollisionShape3D here
		# scale = Vector3(1.5, 1.5, 1.5)
		
	if _level >= 3:
		print("[Lvl 3] Burning DoT effect applied when enemies exit the flame.")
		
	if _level >= 4:
		print("[Lvl 4] Lethal Explosion: Enemies killed by flames will explode.")
		
	if _level >= 5:
		print("[Lvl 5] BLUE FLAMES! Ignores armor and triples damage.")

func _physics_process(delta: float) -> void:
	if is_instance_valid(_controller):
		var spawner = _controller.get_spawn_node() if _controller.has_method("get_spawn_node") else null
		if is_instance_valid(spawner):
			global_position = spawner.global_position
			var dir = _controller.get_forward_direction()
			if dir.length_squared() > 0.01:
				look_at(global_position + dir, Vector3.UP)

	# Continuous damage thicks
	_tick_timer += delta
	if _tick_timer >= _tick_rate:
		_tick_timer = 0.0
		apply_tick_damage()

func _on_body_entered(body: Node3D) -> void:
	var caster = _controller.get_basis_node() if _controller and _controller.has_method("get_basis_node") else null
	var is_caster_enemy = caster and caster.is_in_group("Enemy")
	
	if is_caster_enemy and body.is_in_group("Enemy"):
		return
	if not is_caster_enemy and body.is_in_group("Player"):
		return
		
	if not _victims.has(body):
		_victims.append(body)
		
func _on_body_exited(body: Node3D) -> void:
	if _victims.has(body):
		_victims.erase(body)
		if _level >= 3:
			print("Applying Lingering Burn DoT to ", body.name)

func apply_tick_damage():
	for body in _victims:
		if not is_instance_valid(body):
			continue
		print("Flame tick damaged ", body.name)
		
		# Robust check for HealthComponent
		var hc = body.get("health_component")
		if not hc and body.has_node("HealthComponent"):
			hc = body.get_node("HealthComponent")
		
		if hc and hc.has_method("take_damage"):
			var damage = _driver.get_damage() if (_driver and _driver.has_method("get_damage")) else 10.0
			hc.take_damage(damage)
		elif body.has_method("take_damage"):
			var damage = _driver.get_damage() if (_driver and _driver.has_method("get_damage")) else 10.0
			body.take_damage(damage)
		
		# Example logic:
		# if _level >= 4 and body is dead: trigger_explosion()
