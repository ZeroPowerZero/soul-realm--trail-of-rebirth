class_name IceSpikes
extends Area3D

var throw_spell: ThrowSpell

@export var life_time: float = 3.0
@export var speed_reduction_factor: float = 0.5 # Slows enemy to 50% speed
@export var slow_duration: float = 2.0

var _time: float = 0.0
var _controller: SpellController
var _driver: SpellDriver

# Level-based
var _hit_count: int = 0
var _max_hits: int = 1

# Multi-cast safety
var _is_extra: bool = false

func set_controller(who: SpellController):
	_controller = who

func set_driver(d: SpellDriver, is_extra := false):
	_driver = d
	_is_extra = is_extra

func _ready() -> void:
	if has_node("throw_spell"):
		throw_spell = $throw_spell as ThrowSpell
	else:
		throw_spell = ThrowSpell.new()
		throw_spell.name = "throw_spell"
		add_child(throw_spell)
		
	global_position = _controller.get_spawn_position()
	var dir = _controller.get_forward_direction()
	look_at(global_position + dir, Vector3.UP)
	
	# Add the aim assist component dynamically
	var aim_assist = AimAssistComponent.new()
	add_child(aim_assist)
	aim_assist.setup(self , dir)
	
	throw_spell.change_owner(self )

	setup_from_level()
	check_multi_cast()

func setup_from_level():
	var lvl = _driver.get_level()

	# Level 1 default
	_max_hits = 1

	if lvl >= 2:
		_max_hits = 3 # Pierce through more enemies since it's an ice spike

	if lvl >= 3:
		# Stronger slow effect at level 3
		speed_reduction_factor = 0.25
		slow_duration = 4.0

func _physics_process(delta: float) -> void:
	throw_spell.move(delta)
	
	_time += delta
	if _time > life_time:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	var caster = _controller.get_basis_node() if _controller else null
	var is_caster_enemy = caster and caster.is_in_group("Enemy")
	var is_caster_player = caster and caster.is_in_group("Player")
	
	if is_caster_enemy and body.is_in_group("Enemy"):
		return
	if is_caster_player and body.is_in_group("Player"):
		return
		
	if body.is_in_group("Enemy") or body.is_in_group("Player"):
		apply_damage(body)
		apply_slow(body)
		
		_hit_count += 1
		
		if _hit_count >= _max_hits:
			queue_free()

func apply_damage(body: Node3D):
	# Lower damage than fireball
	var damage = _driver.get_damage() * 0.7
	if body.get("health_component") and body.health_component.has_method("take_damage"):
		body.health_component.take_damage(damage)
	#elif body.has_method("take_damage"):
		#body.take_damage(damage)

func apply_slow(body: Node3D):
	# Assuming enemies have a movement_speed property
	if "movement_speed" in body and not body.has_meta("is_slowed"):
		body.set_meta("is_slowed", true)
		var original_speed = body.movement_speed
		body.movement_speed *= speed_reduction_factor
		
		# Reset speed after duration
		var timer = get_tree().create_timer(slow_duration)
		timer.timeout.connect(func():
			if is_instance_valid(body):
				if "movement_speed" in body:
					body.movement_speed = original_speed
				if body.has_meta("is_slowed"):
					body.remove_meta("is_slowed")
		)

func check_multi_cast():
	if _driver.get_level() >= 4 and not _is_extra:
		spawn_extra_spikes()

func spawn_extra_spikes():
	spawn_delayed(0.2)
	spawn_delayed(0.4)
	spawn_delayed(0.6) # Ice cast shoots more spikes faster

func spawn_delayed(delay: float):
	await get_tree().create_timer(delay).timeout
	
	if not is_instance_valid(_controller):
		return
		
	var new_spell = _driver.get_data().spell_scene.instantiate()
	new_spell.set_controller(_controller)
	new_spell.set_driver(_driver, true)
	
	get_tree().current_scene.add_child(new_spell)
