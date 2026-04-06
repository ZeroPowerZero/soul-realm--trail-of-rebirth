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

func set_driver(d : SpellDriver, _is_extra := false):
	_driver = d

func _ready() -> void:
	if _driver and _driver.has_method("get_level"):
		_level = _driver.get_level()
		
	setup_roguelike_level()

	if _controller:
		global_position = _controller.get_spawn_position()
		var dir = _controller.get_forward_direction()
		if dir.length_squared() > 0.01:
			look_at(global_position + dir, Vector3.UP)
			
		# Optional: Attach flames to the caster so they move together
		if _controller.has_method("get_basis_node"):
			var caster = _controller.get_basis_node()
			if is_instance_valid(caster):
				get_parent().remove_child(self)
				caster.add_child(self)
				# Reset transform relative to caster
				transform = Transform3D.IDENTITY
				position = Vector3(0, 1, -1) # Slightly in front

	var end_timer = get_tree().create_timer(_duration)
	end_timer.timeout.connect(func(): queue_free())
	
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
		
		# Example logic:
		# if body.get("health_component"):
		#     body.health_component.take_damage(damage_amount)
		#     if _level >= 4 and body is dead: trigger_explosion()
