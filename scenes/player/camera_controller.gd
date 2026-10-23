extends Node3D
class_name CameraController

## CameraController - Handles mouse-look, first/third person switching, and gravity-aware orientation.
## Owned by: Player Controller Subsystem
## Integration: Attached to Player scene as child node named "CameraController"

## CONFIGURABLE CAMERA PARAMETERS
@export_group("First Person")
@export var fp_vertical_fov: float = 90.0
@export var fp_near: float = 0.05
@export var fp_far: float = 4000.0

@export_group("Third Person")
@export var tp_distance: float = 4.0
@export var tp_min_distance: float = 1.5
@export var tp_max_distance: float = 10.0
@export var tp_zoom_speed: float = 10.0
@export var tp_vertical_fov: float = 75.0
@export var tp_shoulder_offset: Vector2 = Vector2(0.5, 0.0)  # x=right, y=up

@export_group("Mouse Look")
@export var mouse_sensitivity: float = 0.002
@export var invert_y: bool = false
@export var pitch_limit_min: float = -85.0
@export var pitch_limit_max: float = 85.0

@export_group("Smoothing")
@export var rotation_smoothing: float = 15.0
@export var position_smoothing: float = 20.0

@export_group("Collision")
@export var camera_collision_layers: int = 1
@export var camera_sphere_radius: float = 0.15

@export_group("References")
@export var player_body: NodePath = ".."
@export var camera_3d: NodePath = NodePath("Camera3D")
@export var fp_pivot: NodePath = NodePath("FPPivot")
@export var tp_pivot: NodePath = NodePath("TPPivot")

## SIGNALS
signal camera_mode_changed(is_first_person: bool)
signal gravity_orientation_changed(gravity_dir: Vector3)

## INTERNAL STATE
var _player: CharacterBody3D
var _camera: Camera3D
var _fp_pivot: Node3D
var _tp_pivot: Node3D

var _is_first_person: bool = true
var _yaw: float = 0.0
var _pitch: float = 0.0
var _target_yaw: float = 0.0
var _target_pitch: float = 0.0
var _current_tp_distance: float
var _target_tp_distance: float
var _gravity_dir: Vector3 = Vector3.DOWN
var _mouse_captured: bool = false

func _ready() -> void:
	_player = get_node_or_null(player_body) as CharacterBody3D
	_camera = get_node_or_null(camera_3d) as Camera3D
	_fp_pivot = get_node_or_null(fp_pivot) as Node3D
	_tp_pivot = get_node_or_null(tp_pivot) as Node3D
	
	if not _player:
		push_error("Player body not found at path: ", player_body)
	if not _camera:
		push_error("Camera3D not found at path: ", camera_3d)
	if not _fp_pivot:
		push_warning("FPPivot not found at path: ", fp_pivot, " - first person may not work correctly")
	if not _tp_pivot:
		push_warning("TPPivot not found at path: ", tp_pivot, " - third person may not work correctly")
	
	_current_tp_distance = tp_distance
	_target_tp_distance = tp_distance
	
	# Initialize rotation from current transform
	var basis: Basis = global_transform.basis
	_yaw = atan2(basis.x.x, basis.z.x)
	_pitch = atan2(-basis.y.y, sqrt(basis.y.x * basis.y.x + basis.y.z * basis.y.z))
	_target_yaw = _yaw
	_target_pitch = _pitch
	
	_setup_camera()
	_capture_mouse()

func _setup_camera() -> void:
	_camera.fov = fp_vertical_fov if _is_first_person else tp_vertical_fov
	_camera.near = fp_near
	_camera.far = fp_far
	
	if _is_first_person:
		_tp_pivot.visible = false
		if _fp_pivot:
			_fp_pivot.visible = true
			_camera.global_transform = _fp_pivot.global_transform
	else:
		_fp_pivot.visible = false
		_tp_pivot.visible = true
		_update_third_person_position()

func _process(delta: float) -> void:
	_handle_mouse_capture_toggle()
	
	_smooth_rotation(delta)
	_smooth_position(delta)
	
	_handle_zoom(delta)
	_handle_camera_toggle()

func _handle_mouse_capture_toggle() -> void:
	if Input.is_action_just_pressed("mouse_capture"):
		if _mouse_captured:
			_release_mouse()
		else:
			_capture_mouse()

func _capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_mouse_captured = true

func _release_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_mouse_captured = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _mouse_captured:
		_target_yaw -= event.relative.x * mouse_sensitivity
		_target_pitch += event.relative.y * mouse_sensitivity * (1.0 if invert_y else -1.0)
		_target_pitch = clamp(_target_pitch, deg_to_rad(pitch_limit_min), deg_to_rad(pitch_limit_max))

func _smooth_rotation(delta: float) -> void:
	_yaw = lerp_angle(_yaw, _target_yaw, rotation_smoothing * delta)
	_pitch = lerp_angle(_pitch, _target_pitch, rotation_smoothing * delta)
	
	var yaw_rot: Basis = Basis(Vector3.UP, _yaw)
	var pitch_rot: Basis = Basis(Vector3.RIGHT, _pitch)
	
	# Apply gravity-aware rotation
	var gravity_basis: Basis = _get_gravity_aligned_basis()
	var final_basis: Basis = gravity_basis * yaw_rot * pitch_rot
	
	if _is_first_person:
		if _fp_pivot:
			_fp_pivot.global_basis = final_basis
		_camera.global_basis = final_basis
	else:
		if _tp_pivot:
			_tp_pivot.global_basis = final_basis
		_camera.global_basis = final_basis

func _smooth_position(delta: float) -> void:
	if _is_first_person:
		if _fp_pivot:
			_camera.global_position = _camera.global_position.lerp(_fp_pivot.global_position, position_smoothing * delta)
	else:
		_update_third_person_position()
		_camera.global_position = _camera.global_position.lerp(_tp_pivot.global_position, position_smoothing * delta)

func _update_third_person_position() -> void:
	if not _tp_pivot or not _player:
		return
	
	var player_pos: Vector3 = _player.global_position
	var backward: Vector3 = -_tp_pivot.global_basis.z.normalized()
	var right: Vector3 = _tp_pivot.global_basis.x.normalized()
	var up: Vector3 = _tp_pivot.global_basis.y.normalized()
	
	var target_pos: Vector3 = player_pos + backward * _current_tp_distance
	target_pos += right * tp_shoulder_offset.x
	target_pos += up * tp_shoulder_offset.y
	
	# Camera collision check
	var space_state: PhysicsDirectSpaceState3D = _player.get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(player_pos, target_pos, camera_collision_layers)
	query.hit_from_inside = true
	query.exclude = [_player.get_rid()]
	
	var result: Dictionary = space_state.intersect_ray(query)
	if result:
		var hit_pos: Vector3 = result.position
		var safe_distance: float = (hit_pos - player_pos).length() - camera_sphere_radius
		_current_tp_distance = min(_current_tp_distance, max(safe_distance, tp_min_distance))
	else:
		_current_tp_distance = lerp(_current_tp_distance, _target_tp_distance, tp_zoom_speed * 0.1)
	
	_target_tp_distance = clamp(_target_tp_distance, tp_min_distance, tp_max_distance)
	_current_tp_distance = clamp(_current_tp_distance, tp_min_distance, tp_max_distance)
	
	_tp_pivot.global_position = player_pos + backward * _current_tp_distance + right * tp_shoulder_offset.x + up * tp_shoulder_offset.y

func _handle_zoom(delta: float) -> void:
	if _is_first_person:
		return
	
	var scroll: float = Input.get_axis("zoom_out", "zoom_in")
	if scroll != 0.0:
		_target_tp_distance -= scroll * tp_zoom_speed * delta
		_target_tp_distance = clamp(_target_tp_distance, tp_min_distance, tp_max_distance)

func _handle_camera_toggle() -> void:
	if Input.is_action_just_pressed("toggle_camera"):
		_is_first_person = not _is_first_person
		_setup_camera()
		camera_mode_changed.emit(_is_first_person)

func _get_gravity_aligned_basis() -> Basis:
	# Construct basis where Y aligns with -gravity_dir (up is opposite gravity)
	var up: Vector3 = -_gravity_dir
	var forward: Vector3 = Vector3.FORWARD
	
	# If gravity is close to world up/down, use standard basis
	if abs(up.dot(Vector3.UP)) > 0.99:
		return Basis.IDENTITY
	
	# Otherwise, construct basis from gravity direction
	var right: Vector3 = forward.cross(up).normalized()
	if right.length() < 0.001:
		forward = Vector3.RIGHT
		right = forward.cross(up).normalized()
	forward = up.cross(right).normalized()
	
	return Basis(right, up, -forward).inverse()

func on_gravity_changed(new_gravity_dir: Vector3) -> void:
	"""Called by PlayerController when gravity direction changes."""
	_gravity_dir = new_gravity_dir.normalized()
	
	# Adjust pitch/yaw to maintain relative camera orientation
	# This prevents sudden camera flips when gravity changes
	gravity_orientation_changed.emit(_gravity_dir)

func get_movement_basis() -> Basis:
	"""Returns the horizontal rotation basis for movement (yaw only, gravity-aligned)."""
	var yaw_rot: Basis = Basis(Vector3.UP, _yaw)
	var gravity_basis: Basis = _get_gravity_aligned_basis()
	return gravity_basis * yaw_rot

func is_first_person() -> bool:
	return _is_first_person

func set_first_person(enabled: bool) -> void:
	if _is_first_person != enabled:
		_is_first_person = enabled
		_setup_camera()
		camera_mode_changed.emit(_is_first_person)

func get_camera() -> Camera3D:
	return _camera

## INPUT ACTIONS USED (in addition to PlayerController actions)
## ================================================================
## toggle_camera     - C                  - Toggle first/third person
## mouse_capture     - Escape             - Release/recapture mouse
## zoom_in           - Mouse Wheel Up     - Zoom in (third person)
## zoom_out          - Mouse Wheel Down   - Zoom out (third person)
## ================================================================
## These actions must be defined in Project Settings -> Input Map.
## The integration owner is responsible for adding them to project.godot.
