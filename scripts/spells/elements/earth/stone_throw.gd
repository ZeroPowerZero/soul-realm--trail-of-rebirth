class_name StoneThrow
extends Area3D

@export var forward_speed: float = 15.0
@export var life_time: float = 5.0

var _controller: Node # SpellController
var _driver: SpellDriver # SpellDriver

var _velocity: Vector3 = Vector3.ZERO
var _time: float = 0.0

var _level: int = 1
var _hit_count: int = 0
var _max_hits: int = 1
var _explosion_radius: float = 0.0

func set_controller(who):
	_controller = who

func set_driver(d, _is_extra := false):
	_driver = d

func _ready() -> void:
	if _controller:
		global_position = _controller.get_spawn_position()
	
	if _driver and _driver.has_method("get_level"):
		_level = _driver.get_level()
		
	setup_level()

	# Find target and calculate arc
	var target = find_nearest_target()
	calculate_trajectory(target)
	
	body_entered.connect(_on_body_entered)

func setup_level():
	print("--- Setup Stone Throw Level ", _level, " ---")
	
	if _level >= 1:
		_max_hits = 1
		print("[Lvl 1] Standard single target enabled.")
		
	if _level >= 2:
		_explosion_radius = 2.0
		print("[Lvl 2] Splinter logic added! Small AoE explosion on impact.")
		
	if _level >= 3:
		print("[Lvl 3] Multi-throw potential added! (Handled by casting controller)")
		
	if _level >= 4:
		print("[Lvl 4] Stun effect added to the projectile payload.")
		
	if _level >= 5:
		_explosion_radius = 6.0
		forward_speed = 25.0
		print("[Lvl 5] BOULDER MODE! Massive damage and knockback enabled.")

func find_nearest_target() -> Node3D:
	# Assume we look for enemies if the player cast it
	var caster = _controller.get_basis_node() if _controller and _controller.has_method("get_basis_node") else null
	var target_group = "Enemy"
	if caster and caster.is_in_group("Enemy"):
		target_group = "Player"
		
	var nodes = get_tree().get_nodes_in_group(target_group)
	var best_dist = 99999.0
	var best_node = null
	
	for n in nodes:
		if not is_instance_valid(n): continue
		var d = global_position.distance_squared_to(n.global_position)
		if d < best_dist:
			best_dist = d
			best_node = n
			
	return best_node

func calculate_trajectory(target: Node3D):
	if not is_instance_valid(target):
		# Fallback: Just shoot straight if no targets
		if _controller and _controller.has_method("get_forward_direction"):
			_velocity = _controller.get_forward_direction() * forward_speed
		else:
			_velocity = -transform.basis.z * forward_speed
		return
		
	var start_pos = global_position
	var end_pos = target.global_position + Vector3.UP * 1.0 # Aim for the chest
	
	var dir = end_pos - start_pos
	var h_dist = Vector2(dir.x, dir.z).length()
	var y_dist = dir.y
	
	# t = d / v
	var t = h_dist / forward_speed
	if t <= 0.01:
		_velocity = Vector3.ZERO
		return
		
	# Vy = (h + 0.5 * g * t^2) / t
	var v_y = (y_dist + 0.5 * gravity * t * t) / t
	
	var h_dir = Vector3(dir.x, 0, dir.z).normalized()
	_velocity = h_dir * forward_speed
	_velocity.y = v_y

func _physics_process(delta: float) -> void:
	# Apply gravity and move
	_velocity.y -= gravity * delta
	global_position += _velocity * delta
	
	# Point projectile in the direction of velocity
	if _velocity.length_squared() > 0.1:
		look_at(global_position + _velocity, Vector3.UP)
	
	_time += delta
	if _time > life_time:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	var caster = _controller.get_basis_node() if _controller and _controller.has_method("get_basis_node") else null
	var is_caster_enemy = caster and caster.is_in_group("Enemy")
	
	if is_caster_enemy and body.is_in_group("Enemy"):
		return
	if not is_caster_enemy and body.is_in_group("Player"):
		return
		
	trigger_impact(body)

func trigger_impact(direct_hit_body: Node3D = null):
	print("Stone hit something!")
	
	if _level >= 2:
		print("Triggering Splinter Explosion (AoE: ", _explosion_radius, ")")
		# TODO: Instatiate explosion visual or Area3D check
		
	if _level >= 4 and is_instance_valid(direct_hit_body):
		print("Applying STUN to ", direct_hit_body.name)
		
	if _level >= 5:
		print("Applying MASSIVE KNOCKBACK and Boulder Damage!")
		
	queue_free()
