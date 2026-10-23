extends Node3D

@export var bob_height := 0.2
@export var bob_speed := 0.7

var time := 0.0
var base_position := Vector3.ZERO

func _ready() -> void:
	base_position = position
	var imported_cloud := get_node_or_null("cloud2")
	if imported_cloud:
		imported_cloud.visible = false
	_add_puff(Vector3(-0.72, 0.0, 0.0), 0.62, Color("#d9f4ff"))
	_add_puff(Vector3(0.0, 0.18, 0.0), 0.78, Color("#f7fdff"))
	_add_puff(Vector3(0.72, 0.02, 0.0), 0.62, Color("#e6f8ff"))
	_add_puff(Vector3(-0.12, -0.18, 0.28), 0.52, Color("#eaf9ff"))

func _add_puff(offset: Vector3, radius: float, tint: Color) -> void:
	var puff := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	puff.mesh = sphere
	puff.position = offset
	puff.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.92
	puff.material_override = material
	add_child(puff)

func _process(delta: float) -> void:
	time += delta
	position = base_position + Vector3(0.0, sin(time * bob_speed) * bob_height, sin(time * bob_speed * 0.55) * 0.06)
