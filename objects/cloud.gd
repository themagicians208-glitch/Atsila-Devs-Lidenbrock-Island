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
	_add_cloud_platform()

func _add_cloud_platform() -> void:
	var platform := StaticBody3D.new()
	platform.name = "CloudPlatform"
	var platform_shape := CollisionShape3D.new()
	var platform_box := BoxShape3D.new()
	platform_box.size = Vector3(1.9, 0.38, 1.45)
	platform_shape.shape = platform_box
	platform_shape.position.y = -0.14
	platform.add_child(platform_shape)
	add_child(platform)

	var bounce_zone := Area3D.new()
	bounce_zone.name = "BounceZone"
	bounce_zone.collision_layer = 0
	bounce_zone.collision_mask = 1
	var bounce_shape := CollisionShape3D.new()
	var bounce_box := BoxShape3D.new()
	bounce_box.size = Vector3(1.85, 0.55, 1.4)
	bounce_shape.shape = bounce_box
	bounce_shape.position.y = 0.24
	bounce_zone.add_child(bounce_shape)
	bounce_zone.body_entered.connect(_on_bounce_zone_body_entered)
	add_child(bounce_zone)

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

func _physics_process(delta: float) -> void:
	time += delta
	position = base_position + Vector3(0.0, sin(time * bob_speed) * bob_height, sin(time * bob_speed * 0.55) * 0.06)

func _on_bounce_zone_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.velocity.y <= 0.0 and body.has_method("cloud_bounce"):
		body.cloud_bounce()
