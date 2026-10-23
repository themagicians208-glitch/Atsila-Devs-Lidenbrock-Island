extends Node3D

var body_pivot: Node3D
var left_wing: Node3D
var right_wing: Node3D
var left_leg: Node3D
var right_leg: Node3D
var motion_state := "idle"
var motion_speed := 1.0
var clock := 0.0

const CREAM := Color("fff1d0")
const GOLD := Color("f5c85d")
const WING := Color("f3d987")
const CORAL := Color("ed6757")
const BEAK := Color("f28a3d")
const TEAL := Color("39b9b0")
const DARK := Color("29364a")


func _ready() -> void:
	body_pivot = Node3D.new()
	body_pivot.name = "BodyPivot"
	add_child(body_pivot)

	var cream := _material(CREAM)
	var gold := _material(GOLD)
	var wing_material := _material(WING)
	var coral := _material(CORAL)
	var beak_material := _material(BEAK)
	var teal := _material(TEAL)
	var dark := _material(DARK)
	var white := _material(Color.WHITE)

	_part(body_pivot, "RoundBody", _sphere(), cream, Vector3(0, 0.78, 0.02), Vector3(0.49, 0.59, 0.43))
	_part(body_pivot, "Head", _sphere(), cream, Vector3(0, 1.48, -0.1), Vector3(0.39, 0.38, 0.37))

	# A small three-point comb and soft cheek patches give the bird its own silhouette.
	for i in range(3):
		var comb := _part(body_pivot, "Comb%d" % i, _sphere(), coral,
			Vector3((i - 1) * 0.16, 1.83 + (0.06 if i == 1 else 0.0), -0.08),
			Vector3(0.105, 0.17, 0.105))
		comb.rotation.z = deg_to_rad(-12.0 * (i - 1))
	_part(body_pivot, "Wattle", _sphere(), coral, Vector3(0, 1.18, -0.42), Vector3(0.105, 0.15, 0.08))
	_part(body_pivot, "Beak", _cone(), beak_material, Vector3(0, 1.42, -0.48), Vector3(0.19, 0.23, 0.19), Vector3(-PI / 2.0, 0, 0))

	for side in [-1.0, 1.0]:
		var eye_x: float = float(side) * 0.19
		_part(body_pivot, "EyeWhite", _sphere(), white, Vector3(eye_x, 1.52, -0.405), Vector3(0.105, 0.13, 0.06))
		_part(body_pivot, "Eye", _sphere(), dark, Vector3(eye_x, 1.52, -0.46), Vector3(0.055, 0.078, 0.035))
		_part(body_pivot, "EyeSpark", _sphere(), white, Vector3(eye_x - 0.018, 1.55, -0.49), Vector3(0.018, 0.024, 0.012))

	# Teal neckerchief and two short tails make this a little sky-racing courier.
	_part(body_pivot, "ScarfKnot", _sphere(), teal, Vector3(0.25, 1.18, -0.15), Vector3(0.14, 0.13, 0.12))
	_part(body_pivot, "ScarfTailA", _box(), teal, Vector3(0.30, 1.00, 0.0), Vector3(0.09, 0.22, 0.055), Vector3(0, 0, -0.28))
	_part(body_pivot, "ScarfTailB", _box(), teal, Vector3(0.20, 0.98, 0.03), Vector3(0.08, 0.17, 0.05), Vector3(0, 0, 0.30))

	left_wing = _make_wing("WingLeft", -1.0, wing_material, gold)
	right_wing = _make_wing("WingRight", 1.0, wing_material, gold)
	body_pivot.add_child(left_wing)
	body_pivot.add_child(right_wing)

	# Three little tail feathers point behind the bird.
	for i in range(3):
		var tail := _part(body_pivot, "TailFeather%d" % i, _sphere(), wing_material,
			Vector3((i - 1) * 0.15, 0.98 + (0.08 if i == 1 else 0.0), 0.46),
			Vector3(0.12, 0.17, 0.23))
		tail.rotation.x = deg_to_rad(-28)

	left_leg = _make_leg("LegLeft", -1.0, beak_material)
	right_leg = _make_leg("LegRight", 1.0, beak_material)
	body_pivot.add_child(left_leg)
	body_pivot.add_child(right_leg)


func set_motion(state: String, speed: float = 1.0) -> void:
	motion_state = state
	motion_speed = clampf(speed, 0.6, 2.5)


func _process(delta: float) -> void:
	clock += delta
	if body_pivot == null:
		return
	var phase := clock * (11.0 * motion_speed)
	var bob := 0.0
	if motion_state == "walk":
		bob = absf(sin(phase)) * 0.08
		left_leg.rotation.x = sin(phase) * 0.55
		right_leg.rotation.x = sin(phase + PI) * 0.55
		left_wing.rotation.z = -0.12 + sin(phase) * 0.18
		right_wing.rotation.z = 0.12 - sin(phase) * 0.18
	elif motion_state == "jump":
		bob = 0.035
		left_wing.rotation.z = -0.72 + sin(clock * 18.0) * 0.12
		right_wing.rotation.z = 0.72 - sin(clock * 18.0) * 0.12
		left_leg.rotation.x = -0.35
		right_leg.rotation.x = -0.35
	else:
		bob = sin(clock * 2.3) * 0.018
		left_wing.rotation.z = -0.08
		right_wing.rotation.z = 0.08
		left_leg.rotation.x = 0.0
		right_leg.rotation.x = 0.0
	body_pivot.position.y = bob
	body_pivot.rotation.z = sin(clock * 1.8) * (0.035 if motion_state == "idle" else 0.0)


func _make_wing(node_name: String, side: float, feather_material: StandardMaterial3D, tip_material: StandardMaterial3D) -> Node3D:
	var wing := Node3D.new()
	wing.name = node_name
	wing.position = Vector3(side * 0.40, 0.92, -0.02)
	_part(wing, "Wing", _sphere(), feather_material, Vector3(side * 0.12, 0, 0), Vector3(0.24, 0.29, 0.16))
	for i in range(2):
		_part(wing, "Feather%d" % i, _sphere(), tip_material,
			Vector3(side * (0.23 + i * 0.035), -0.12 - i * 0.09, -0.015), Vector3(0.105, 0.12, 0.11))
	return wing


func _make_leg(node_name: String, side: float, material: StandardMaterial3D) -> Node3D:
	var leg := Node3D.new()
	leg.name = node_name
	leg.position = Vector3(side * 0.21, 0.30, -0.015)
	_part(leg, "Shin", _cylinder(), material, Vector3(0, -0.10, 0), Vector3(0.065, 0.18, 0.065))
	_part(leg, "Foot", _sphere(), material, Vector3(0, -0.23, -0.09), Vector3(0.13, 0.055, 0.18))
	for toe in range(3):
		_part(leg, "Toe%d" % toe, _sphere(), material,
			Vector3((toe - 1) * 0.075, -0.24, -0.21), Vector3(0.055, 0.045, 0.13))
	return leg


func _part(parent: Node3D, node_name: String, mesh: Mesh, material: StandardMaterial3D, pos: Vector3, size: Vector3, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	instance.scale = size
	instance.rotation = rot
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)
	return instance


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.78
	return material


func _sphere() -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radial_segments = 16
	mesh.rings = 10
	return mesh


func _cone() -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.bottom_radius = 0.5
	mesh.top_radius = 0.0
	mesh.radial_segments = 12
	return mesh


func _cylinder() -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.radial_segments = 10
	return mesh


func _box() -> BoxMesh:
	return BoxMesh.new()
