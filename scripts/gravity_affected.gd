extends Node

class_name GravityAffected

## Interface for objects that react to gravity changes
## Attach this to any Node3D that should respond to gravity shifts
## Supports both GravityShiftComponent and PlayerController as gravity sources

signal gravity_affected_changed(is_reversed: bool, gravity_vector: Vector3)

@export_group("Gravity Response")
@export var follow_gravity_direction: bool = true
@export var rotate_to_align: bool = false
@export var rotation_speed: float = 5.0
@export var apply_gravity_force: bool = false
@export var gravity_force_multiplier: float = 1.0

@export_group("Visual Feedback")
@export var tint_on_shift: bool = true
@export var normal_tint: Color = Color.WHITE
@export var reversed_tint: Color = Color(0.8, 0.5, 1.0, 1.0)
@export var tint_duration: float = 0.3

@export_group("Integration")
@export var gravity_source_path: NodePath = ""

var _gravity_component: GravityShiftComponent
var _player_controller: PlayerController
var _rigid_body: RigidBody3D
var _mesh_instance: MeshInstance3D
var _material_override: StandardMaterial3D
var _current_gravity: Vector3 = Vector3.DOWN * 9.8
var _is_reversed: bool = false

func _ready() -> void:
	_find_gravity_source()
	_setup_visual_feedback()
	
	if _gravity_component:
		_gravity_component.gravity_changed.connect(_on_gravity_changed.bind())
		_is_reversed = _gravity_component.is_gravity_reversed()
		_current_gravity = _gravity_component.get_gravity_vector()
	elif _player_controller:
		_player_controller.gravity_changed.connect(_on_player_gravity_changed.bind())
		_is_reversed = _player_controller.get_gravity_direction().dot(Vector3.UP) > 0
		_current_gravity = _player_controller.get_gravity_direction() * _player_controller.get_gravity_strength()

func _find_gravity_source() -> void:
	# Try explicit path first
	if gravity_source_path != "":
		var node = get_node_or_null(gravity_source_path)
		if node is GravityShiftComponent:
			_gravity_component = node
			return
		elif node is PlayerController:
			_player_controller = node
			return
	
	# Try owner
	var owner = get_owner()
	if owner:
		if owner.has_node("GravityShiftComponent"):
			_gravity_component = owner.get_node("GravityShiftComponent")
			return
		if owner is PlayerController:
			_player_controller = owner
			return
	
	# Try gravity_shifter group
	for node in get_tree().get_nodes_in_group("gravity_shifter"):
		if node is GravityShiftComponent:
			_gravity_component = node
			return
		if node is PlayerController:
			_player_controller = node
			return

func _setup_visual_feedback() -> void:
	if not tint_on_shift:
		return
	_mesh_instance = _find_mesh_instance()
	if _mesh_instance:
		_material_override = StandardMaterial3D.new()
		_material_override.albedo_color = normal_tint
		_material_override.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
		_mesh_instance.set_surface_override_material(0, _material_override)

func _find_mesh_instance() -> MeshInstance3D:
	for child in get_children():
		if child is MeshInstance3D:
			return child
		var found = _find_mesh_recursive(child)
		if found:
			return found
	return null

func _find_mesh_recursive(node: Node) -> MeshInstance3D:
	for child in node.get_children():
		if child is MeshInstance3D:
			return child
		var found = _find_mesh_recursive(child)
		if found:
			return found
	return null

func _on_gravity_changed(is_reversed: bool, gravity_vector: Vector3) -> void:
	_is_reversed = is_reversed
	_current_gravity = gravity_vector
	
	if tint_on_shift and _material_override:
		var target = reversed_tint if is_reversed else normal_tint
		var tween = create_tween()
		tween.tween_property(_material_override, "albedo_color", target, tint_duration)
		tween.set_ease(Tween.EASE_OUT)
	
	if rotate_to_align and not _is_shifting():
		_start_rotation_align()
	
	gravity_affected_changed.emit(is_reversed, gravity_vector)

func _on_player_gravity_changed(gravity_direction: Vector3) -> void:
	var is_reversed = gravity_direction.dot(Vector3.UP) > 0
	var gravity_vector = gravity_direction * _player_controller.get_gravity_strength()
	_on_gravity_changed(is_reversed, gravity_vector)

func _is_shifting() -> bool:
	return _gravity_component and _gravity_component.get_state()["is_shifting"]

func _start_rotation_align() -> void:
	var target_up = _current_gravity.normalized() * -1.0
	var current_up = global_transform.basis.get_column(1).normalized()
	
	if current_up.dot(target_up) < 0.99:
		var target_basis = Basis.looking_at(-_current_gravity, global_transform.basis.get_column(2))
		var tween = create_tween()
		tween.tween_method(Callable(self, "_rotate_towards").bind(target_basis), 0.0, 1.0, 1.0 / rotation_speed)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_QUAD)

func _rotate_towards(target_basis: Basis, t: float) -> void:
	global_transform.basis = global_transform.basis.slerp(target_basis, t)

func _physics_process(delta: float) -> void:
	if apply_gravity_force and _rigid_body:
		_rigid_body.apply_force(_current_gravity * gravity_force_multiplier * _rigid_body.mass)

## Public API for external control
func set_gravity_source(component: GravityShiftComponent) -> void:
	if _gravity_component:
		_gravity_component.gravity_changed.disconnect(_on_gravity_changed.bind())
	_gravity_component = component
	if _gravity_component:
		_gravity_component.gravity_changed.connect(_on_gravity_changed.bind())
		_is_reversed = _gravity_component.is_gravity_reversed()
		_current_gravity = _gravity_component.get_gravity_vector()

func get_gravity_vector() -> Vector3:
	return _current_gravity

func is_gravity_reversed() -> bool:
	return _is_reversed

func get_up_direction() -> Vector3:
	return _current_gravity.normalized() * -1.0