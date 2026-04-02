#class_name FireBall
#extends Area3D
#
#@onready var throw_spell: ThrowSpell = $throw_spell
#
#@export var life_time: float = 3
#var _time: float
#
#var _controller: SpellController
#
#func _ready() -> void:
	#global_position = _controller.get_spawn_position()
	#
	#var dir = _controller.get_forward_direction()
	#look_at(global_position + dir, Vector3.UP)
	#
	#throw_spell.change_owner(self)
#
#func _physics_process(delta: float) -> void:
	#throw_spell.move(delta)
	#
	#_time += delta
	#if _time > life_time:
		#queue_free()
#
#func set_controller(who: SpellController):
	#_controller = who
#
#
#func _on_body_entered(body: Node3D) -> void:
	#if body is CharacterBody3D and body.health_component.has_method("take_damage"):
		#body.health_component.take_damage(50);
		#queue_free()
class_name FireBall
extends Area3D

@onready var throw_spell: ThrowSpell = $throw_spell

@export var life_time: float = 3.0

var _time: float = 0.0
var _controller: SpellController
var _driver: SpellDriver

# Level-based
var _hit_count: int = 0
var _max_hits: int = 1

# Multi-cast safety
var _is_extra: bool = false

# Explosion
var _can_explode: bool = false
var _exploded: bool = false


func set_controller(who: SpellController):
	_controller = who

func set_driver(d: SpellDriver, is_extra := false):
	_driver = d
	_is_extra = is_extra


func _ready() -> void:
	global_position = _controller.get_spawn_position()
	var dir = _controller.get_forward_direction()
	look_at(global_position + dir, Vector3.UP)
	
	# Add the aim assist component dynamically
	var aim_assist = AimAssistComponent.new()
	add_child(aim_assist)
	aim_assist.setup(self, dir)
	
	throw_spell.change_owner(self)

	setup_from_level()
	check_multi_cast()


func setup_from_level():
	var lvl = _driver.get_level()

	# Level 1 default
	_max_hits = 1

	if lvl >= 2:
		_max_hits = 2  # penetration

	if lvl >= 3:
		_can_explode = true


func _physics_process(delta: float) -> void:
	throw_spell.move(delta)
	
	_time += delta
	if _time > life_time:
		trigger_explosion()
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemy"):
		apply_damage(body)
		
		_hit_count += 1
		
		if _hit_count >= _max_hits:
			trigger_explosion()
			queue_free()


func apply_damage(body):
	var damage = _driver.get_damage()
	print("Damage ", damage)
	if body.health_component.has_method("take_damage"):
		body.health_component.take_damage(damage )


func trigger_explosion():
	if not _can_explode or _exploded:
		return
	
	_exploded = true
	
	# TODO: Replace with actual explosion system later
	print("BOOM at ", global_position)

	# Example placeholder logic:
	for body in get_overlapping_bodies():
		if body.is_in_group("enemies"):
			apply_damage(body)


func check_multi_cast():
	if _driver.get_level() >= 4 and not _is_extra:
		spawn_extra_fireballs()


func spawn_extra_fireballs():
	spawn_delayed(0.3)
	spawn_delayed(0.6)


func spawn_delayed(delay: float):
	await get_tree().create_timer(delay).timeout
	
	if not is_instance_valid(_controller):
		return
	
	var new_spell = _driver.get_data().spell_scene.instantiate()
	new_spell.set_controller(_controller)
	new_spell.set_driver(_driver, true)  # prevent recursion
	
	get_tree().current_scene.add_child(new_spell)
