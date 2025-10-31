@tool
extends EditorScript


func _run() -> void:
	var scene_root = EditorInterface.get_edited_scene_root()
	for child in scene_root.get_children():
		if child is MeshInstance3D:
			var body = StaticBody3D.new()
			var col_shape = CollisionShape3D.new()
			var shape = child.mesh.create_convex_shape(true, true)
			col_shape.shape = shape
			child.add_child(body, true)
			body.add_child(col_shape, true)
			body.owner = scene_root
			col_shape.owner = scene_root
	print('done')
