extends Node

class_name GravityShiftComponent

## Gravity Shift Component - Handles player-initiated gravity reversal
## Integration: Calls PlayerController.set_gravity_direction() for physics changes
## Emits signals for GravityAffected, GravityZone, and other puzzle systems

signal gravity_changed(is_reversed: bool, gravity_vector: Vector3)
signal gravity_shift_started(is_reversed: bool)
signal gravity_shift_completed(is_reversed: bool)

@export_group("Gravity Settings")
@export var gravity_magnitude: float = 9.81
@export var reversed_gravity_multiplier: float = 1.0

@export_group("Cooldown & Stability")
@export var cooldown_time: float = 0.5
@export var shift_duration: float = 0.3
@export var require_grounded: bool = false
@export var check_ceiling_clearance: bool = true
@export var ceiling_clearance: float = 1.0

@export_group("Visual Feedback")
@export var enable_color_tint: bool = true
@export var normal_color: Color = Color(0.2, 0.6, 1.0, 1.0)
@export var reversed_color: Color = Color(1.0, 0.4, 0.8, 1.0)
@export var tint_duration: float = 0.2
@export var enable_particles: bool = true
@export var particle_amount: int = 20

@export_group("Input")
@export var input_action: StringName = "gravity_shift"

@export_group("Integration")
@export var player_controller_path: NodePath = ".."

var _is_reversed: bool = false
var _is_shifting: bool = false
var _cooldown_timer: float = 0.0
var _shift_timer: float = 0.0
var _player_controller: PlayerController
var _mesh_instance: MeshInstance3D
var _particle_system: GPUParticles3D
var _material_override: StandardMaterial3D
var _original_material: Material

func _ready() -> void:
	_player_controller = get_node_or_null(player_controller_path) as PlayerController
	if not _player_controller:
		push_error("GravityShiftComponent: PlayerController not found at path: ", player_controller_path)
		return
	
	add_to_group("gravity_shifter")
	
	_setup_visual_feedback()
	_player_controller.gravity_changed.connect(_on_player_gravity_changed.bind())
	
	# Initialize from player controller
	_is_reversed = _player_controller.get_gravity_direction().dot(Vector3.UP) > 0

func _physics_process(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta
	
	if _is_shifting:
		_shift_timer -= delta
		if _shift_timer <= 0.0:
			_complete_shift()
	
	_handle_input()

func _handle_input() -> void:
	if Input.is_action_just_pressed(input_action) and _can_shift():
		_request_shift()

func _can_shift() -> bool:
	if _is_shifting or _cooldown_timer > 0.0:
		return false
	if require_grounded and not _player_controller.is_grounded():
		return false
	if check_ceiling_clearance and _would_trap_player():
		return false
	return true

func _would_trap_player() -> bool:
	if not _player_controller:
		return false
	var space_state = _player_controller.get_world_3d().direct_space_state
	var player_pos = _player_controller.global_position
	var up_dir = Vector3.DOWN if _is_reversed else Vector3.UP
	var params = PhysicsRayQueryParameters3D.create(
		player_pos,
		player_pos + up_dir * (ceiling_clearance + 0.1),
		_player_controller.collision_layer
	)
	params.exclude = [_player_controller.get_rid()]
	var result = space_state.intersect_ray(params)
	return result.size() > 0

func _request_shift() -> void:
	_is_shifting = true
	_shift_timer = shift_duration
	var new_reversed = not _is_reversed
	gravity_shift_started.emit(new_reversed)

func _complete_shift() -> void:
	if not _player_controller:
		_is_shifting = false
		return
	
	_is_shifting = false
	_is_reversed = not _is_reversed
	_cooldown_timer = cooldown_time
	
	var new_gravity_dir = Vector3.UP if _is_reversed else Vector3.DOWN
	var new_gravity_strength = gravity_magnitude * (reversed_gravity_multiplier if _is_reversed else 1.0)
	
	# Call PlayerController API - this is the integration point
	_player_controller.set_gravity_direction(new_gravity_dir)
	_player_controller.set_gravity_strength(new_gravity_strength)
	
	_apply_visual_feedback()
	gravity_changed.emit(_is_reversed, new_gravity_dir * new_gravity_strength)
	gravity_shift_completed.emit(_is_reversed)

func _on_player_gravity_changed(gravity_direction: Vector3) -> void:
	# Sync internal state with PlayerController (in case of external changes)
	var was_reversed = _is_reversed
	_is_reversed = gravity_direction.dot(Vector3.UP) > 0

func _setup_visual_feedback() -> void:
	_mesh_instance = _find_mesh_instance()
	
	if enable_particles:
		_particle_system = GPUParticles3D.new()
		_particle_system.name = "GravityShiftParticles"
		_particle_system.amount = particle_amount
		_particle_system.lifetime = 0.5
		_particle_system.one_shot = true
		_particle_system.emission_shape = GPUParticles3D.EMISSION_SHAPE_SPHERE
		_particle_system.emission_sphere_radius = 0.5
		_particle_system.scale = Vector3(0.1, 0.1, 0.1)
		_particle_system.gravity = Vector3.ZERO
		_particle_system.initial_velocity = 2.0
		_particle_system.velocity_random = 0.5
		_particle_system.color_initial_ramp = Gradient.new()
		var grad: Gradient = _particle_system.color_initial_ramp
		grad.set_offsets(PackedFloat32Array([0.0, 1.0]))
		grad.set_colors(PackedColorArray([Color(0.5, 0.8, 1.0, 1.0), Color(0.5, 0.8, 1.0, 0.0)]))
		_player_controller.add_child(_particle_system)
	
	if enable_color_tint and _mesh_instance:
		_original_material = _mesh_instance.get_surface_override_material(0)
		_material_override = StandardMaterial3D.new()
		_material_override.albedo_color = normal_color
		_material_override.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
		_mesh_instance.set_surface_override_material(0, _material_override)

func _find_mesh_instance() -> MeshInstance3D:
	if not _player_controller:
		return null
	for child in _player_controller.get_children():
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

func _apply_visual_feedback() -> void:
	if enable_particles and _particle_system:
		_particle_system.global_position = _player_controller.global_position
		_particle_system.restart()
	
	if enable_color_tint and _material_override:
		var target_color = reversed_color if _is_reversed else normal_color
		var tween = create_tween()
		tween.tween_property(_material_override, "albedo_color", target_color, tint_duration)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_QUAD)

## Public API
func is_gravity_reversed() -> bool:
	return _is_reversed

func get_gravity_vector() -> Vector3:
	if not _player_controller:
		return Vector3.DOWN * gravity_magnitude
	var dir = _player_controller.get_gravity_direction()
	var strength = _player_controller.get_gravity_strength()
	return dir * strength

func get_up_direction() -> Vector3:
	return Vector3.DOWN if _is_reversed else Vector3.UP

func force_shift(reversed: bool) -> bool:
	if _is_shifting or _is_reversed == reversed:
		return false
	if check_ceiling_clearance and _would_trap_player():
		return false
	_is_reversed = reversed
	_complete_shift()
	return true

func set_cooldown(time: float) -> void:
	cooldown_time = time

func set_enabled(enabled: bool) -> void:
	set_process(enabled)
	set_physics_process(enabled)
	if not enabled:
		_is_shifting = false
		_cooldown_timer = 0.0

func get_state() -> Dictionary:
	return {
		"is_reversed": _is_reversed,
		"is_shifting": _is_shifting,
		"cooldown_remaining": max(0.0, _cooldown_timer),
		"gravity_vector": get_gravity_vector(),
		"up_direction": get_up_direction()
	}