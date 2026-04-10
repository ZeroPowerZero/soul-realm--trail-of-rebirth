extends Node3D
## Lightweight helper for the static Hades map.
## Generates trimesh collision for every MeshInstance3D in the scene
## and bakes the NavigationMesh at runtime.

func _ready() -> void:
	# Give one frame for all instanced scenes to finish loading
	await get_tree().process_frame
	_add_collision_recursive(self)
	_bake_navmesh()

# ── Collision ─────────────────────────────────────────────────────────────────

func _add_collision_recursive(node: Node) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		if mi.mesh and not _has_collision_child(mi):
			var body := StaticBody3D.new()
			body.name = mi.name + "_col"
			mi.add_child(body)

			var col := CollisionShape3D.new()
			col.shape = mi.mesh.create_trimesh_shape()
			body.add_child(col)

	for child in node.get_children():
		if child is StaticBody3D:
			continue
		_add_collision_recursive(child)

func _has_collision_child(node: Node) -> bool:
	for child in node.get_children():
		if child is StaticBody3D or child is CollisionShape3D:
			return true
	return false

# ── NavMesh ───────────────────────────────────────────────────────────────────

func _bake_navmesh() -> void:
	var nav := get_node_or_null("NavigationRegion3D") as NavigationRegion3D
	if nav and nav.navigation_mesh:
		nav.bake_navigation_mesh(true)
