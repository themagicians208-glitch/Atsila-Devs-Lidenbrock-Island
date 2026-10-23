extends Area3D
class_name GravityZone

@export var gravity_vector: Vector3 = Vector3(0, -9.8, 0)
@export var allowed_directions: Array[Vector3] = [Vector3(0, -9.8, 0), Vector3(0, 9.8, 0), Vector3(9.8, 0, 0), Vector3(-9.8, 0, 0), Vector3(0, 0, 9.8), Vector3(0, 0, -9.8)]
@export var show_visual: bool = false

var _bodies_inside: Array[Node3D] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	var visual_indicator = get_node_or_null("VisualIndicator")
	if visual_indicator:
		visual_indicator.visible = show_visual
	add_to_group("gravity_zones")

func _on_body_entered(body: Node3D) -> void:
	if body not in _bodies_inside:
		_bodies_inside.append(body)
		if body.has_method("apply_gravity_shift"):
			body.apply_gravity_shift(gravity_vector)

func _on_body_exited(body: Node3D) -> void:
	_bodies_inside.erase(body)

func get_gravity_vector() -> Vector3:
	return gravity_vector

func get_allowed_directions() -> Array[Vector3]:
	return allowed_directions