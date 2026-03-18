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
	
	enable()
	
	connect("child_exiting_tree", _on_child_exiting_tree)
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		disable()
		return
	
	_spawn_time += delta
	if _spawn_time > spawn_interval and !enemies.is_empty():
		for i in max_spawn-instantiated_enemies.size():
			var new_ins = enemies.pick_random().enemy_scene.instantiate()
			new_ins.position = Vector3(position.x, 2, position.z)
			add_child(new_ins)
			instantiated_enemies.append(new_ins)
		_spawn_time = 0
		disable()

func _on_child_exiting_tree(node: Node) -> void:
	if instantiated_enemies.has(node):
		_spawn_time = 0
		enable()

func _on_body_entered(body: Node3D):
	if body.is_in_group("Player"):
		for enemy in instantiated_enemies:
			enemy.see_target(body)
func _on_body_exited(body: Node3D):
	if body.is_in_group("Player"):
		for enemy in instantiated_enemies:
			enemy.forget_target(body)

func enable():
	set_process(true)
func disable():
	set_process(false)
