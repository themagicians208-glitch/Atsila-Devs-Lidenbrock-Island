extends Node3D

func _ready() -> void:
	_add_eye(Vector3(-0.105, 0.39, 0.31))
	_add_eye(Vector3(0.105, 0.39, 0.31))

func _add_eye(offset: Vector3) -> void:
	var eye := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.052
	sphere.height = 0.104
	eye.mesh = sphere
	eye.position = offset
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("#10131b")
	material.roughness = 0.35
	eye.material_override = material
	get_node("character/root/torso").add_child(eye)
