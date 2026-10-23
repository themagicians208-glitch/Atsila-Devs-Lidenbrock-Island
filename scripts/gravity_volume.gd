extends Area3D

class_name GravityVolume

## Area that applies custom gravity to objects inside it
## Use for puzzle zones with localized gravity effects

signal body_entered_gravity(body: Node3D, gravity_vector: Vector3)
signal body_exited_gravity(body: Node3D)

@export_group("Volume Gravity")
@export var gravity_vector: Vector3 = Vector3.DOWN * 9.8
@export var priority: int = 0
@export var affect_player: bool = true
@export var affect_rigid_bodies: bool = true
@export var affect_character_bodies: bool = true

@export_group("Transition")
@export var blend_distance: float = 1.0
@export var blend_time: float = 0.5

var _bodies_inside: Dictionary = {}
var _gravity_shifter: GravityShiftComponent

func _ready() -> void:
	body_entered.connect(_on_body_entered.bind())
	body_exited.connect(_on_body_exited.bind())
	
	for group in get_groups():
		if group == "gravity_shifter":
			for node in get_tree().get_nodes_in_group(group):
				if node is GravityShiftComponent:
					_gravity_shifter = node
					break

func _on_body_entered(body: Node3D) -> void:
	if not _should_affect(body):
		return
	
	var original_gravity = _get_original_gravity(body)
	_bodies_inside[body.get_instance_id()] = {
		"body": body,
		"original_gravity": original_gravity,
		"blend_timer": 0.0
	}
	body_entered_gravity.emit(body, gravity_vector)
	_apply_gravity(body, gravity_vector, 0.0)

func _on_body_exited(body: Node3D) -> void:
	var id = body.get_instance_id()
	if not _bodies_inside.has(id):
		return
	
	var data = _bodies_inside[id]
	var original = data["original_gravity"]
	_apply_gravity(body, original, 0.0)
	_bodies_inside.erase(id)
	body_exited_gravity.emit(body)

func _should_affect(body: Node3D) -> bool:
	if affect_player and body is CharacterBody3D and body.has_node("GravityShiftComponent"):
		return false
	if affect_rigid_bodies and body is RigidBody3D:
		return true
	if affect_character_bodies and body is CharacterBody3D:
		return true
	return false

func _get_original_gravity(body: Node3D) -> Vector3:
	if body is RigidBody3D:
		return body.gravity_scale * (ProjectSettings.get_setting("physics/3d/default_gravity") * Vector3.DOWN)
	if body is CharacterBody3D:
		return body.gravity
	return ProjectSettings.get_setting("physics/3d/default_gravity") * Vector3.DOWN

func _apply_gravity(body: Node3D, grav: Vector3, blend: float) -> void:
	if body is RigidBody3D:
		var default_grav = ProjectSettings.get_setting("physics/3d/default_gravity")
		body.gravity_scale = grav.length() / default_grav
		body.gravity = grav.normalized()
	elif body is CharacterBody3D:
		body.gravity = grav

func _physics_process(delta: float) -> void:
	for id in _bodies_inside.keys():
		var data = _bodies_inside[id]
		if not is_instance_valid(data["body"]):
			_bodies_inside.erase(id)
			continue
		
		data["blend_timer"] += delta
		var t = min(1.0, data["blend_timer"] / blend_time)
		_apply_gravity(data["body"], gravity_vector, t)

func get_gravity_vector() -> Vector3:
	return gravity_vector

func set_gravity_vector(vec: Vector3) -> void:
	gravity_vector = vec
	for id in _bodies_inside.keys():
		var data = _bodies_inside[id]
		if is_instance_valid(data["body"]):
			data["blend_timer"] = 0.0