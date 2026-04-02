@tool
class_name NpcArea
extends Area3D

@onready var collision: CollisionShape3D = $CollisionShape3D

@export var max_spawn: int = 5
@export var spawn_interval: float = 60
@export var area_radius: float = 7:
	set(value):
		area_radius = value
		collision.shape.radius = value
@export var enemies: Array[NPC_RESOURCE]

var instantiated_enemies: Array
var _spawn_time: float

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	instantiated_enemies = []
	set_enable(true)
	
	connect("child_exiting_tree", _on_child_exiting_tree)
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		set_enable(false)
		return
	
	_spawn_time += delta
	if _spawn_time > spawn_interval and !enemies.is_empty():
		for i in max_spawn-instantiated_enemies.size():
			var enemy_resource: NPC_RESOURCE = enemies.pick_random()
			if !enemy_resource or !enemy_resource.enemy_scene:
				continue

			var new_ins := enemy_resource.enemy_scene.instantiate() as Node3D
			if !new_ins:
				continue
			add_child(new_ins)
			new_ins.global_position = _get_random_spawn_position()

			for body in get_overlapping_bodies():
				if body.is_in_group("Player") and new_ins.has_method("see_target"):
					new_ins.see_target(body)

			instantiated_enemies.append(new_ins)
		_spawn_time = 0
		set_enable(false)

func _on_child_exiting_tree(node: Node) -> void:
	if instantiated_enemies.has(node):
		instantiated_enemies.erase(node)
		_spawn_time = 0
		set_enable(true)

func _on_body_entered(body: Node3D):
	if body.is_in_group("Player"):
		for enemy in instantiated_enemies:
			enemy.see_target(body)
	
func _on_body_exited(body: Node3D):
	if body.is_in_group("Player"):
		for enemy in instantiated_enemies:
			enemy.forget_target(body)

func set_enable(enable: bool):
	set_process(enable)

func _get_random_spawn_position() -> Vector3:
	var angle: float = randf() * TAU
	var distance: float = sqrt(randf()) * area_radius
	var offset: Vector3 = Vector3(cos(angle), 0, sin(angle)) * distance
	return global_position + offset + Vector3(0, 2, 0)
