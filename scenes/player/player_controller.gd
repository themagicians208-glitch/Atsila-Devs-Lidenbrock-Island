extends CharacterBody3D
class_name PlayerController

## PlayerController - Core movement and physics for the player.
## Owned by: Player Controller Subsystem
## Integration API for Gravity Shift subsystem:
##   - set_gravity_direction(direction: Vector3) -> void
##   - get_gravity_direction() -> Vector3
##   - on_gravity_changed(callable) -> void (signal)

## CONFIGURABLE MOVEMENT PARAMETERS
@export_group("Movement")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 10.0
@export var acceleration: float = 20.0
@export var air_acceleration: float = 10.0
@export var friction: float = 15.0

@export_group("Jumping")
@export var jump_velocity: float = 7.5
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

@export_group("Gravity")
@export var base_gravity: float = 9.81
@export var max_fall_speed: float = 30.0

@export_group("Fall Recovery")
@export var fall_death_height: float = -50.0
@export var reset_position: Vector3 = Vector3.ZERO

@export_group("References")
@export var camera_controller: NodePath = %CameraController

## SIGNALS
signal gravity_changed(gravity_direction: Vector3)
signal fell_out_of_world(reset_pos: Vector3)

## INTERNAL STATE
var _gravity_direction: Vector3 = Vector3.DOWN
var _gravity_strength: float = 9.81
var _velocity: Vector3 = Vector3.ZERO
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _was_on_floor: bool = false
var _camera_controller: CameraController
var _input_vector: Vector2 = Vector2.ZERO
var _is_sprinting: bool = false
var _wants_jump: bool = false

func _ready() -> void:
	_camera_controller = get_node_or_null(camera_controller) as CameraController
	if not _camera_controller:
		push_error("CameraController not found at path: ", camera_controller)
	
	_gravity_direction = Vector3.DOWN
	_gravity_strength = base_gravity
	_velocity = Vector3.ZERO
	
	# Ensure reset_position is set if not configured
	if reset_position == Vector3.ZERO:
		reset_position = global_position

func _physics_process(delta: float) -> void:
	_process_input()
	_handle_coyote_and_buffer(delta)
	_apply_gravity(delta)
	_handle_movement(delta)
	_handle_jump()
	_check_fall_recovery()
	_velocity = move_and_slide(_velocity)
	_was_on_floor = is_on_floor()

func _process_input() -> void:
	_input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("move_forward"):
		_input_vector.y -= 1.0
	if Input.is_action_pressed("move_backward"):
		_input_vector.y += 1.0
	if Input.is_action_pressed("move_left"):
		_input_vector.x -= 1.0
	if Input.is_action_pressed("move_right"):
		_input_vector.x += 1.0
	
	_input_vector = _input_vector.clamped(1.0)
	
	_is_sprinting = Input.is_action_pressed("sprint")
	_wants_jump = Input.is_action_just_pressed("jump")
	
	if _wants_jump:
		_jump_buffer_timer = jump_buffer_time

func _handle_coyote_and_buffer(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer -= delta
	
	_jump_buffer_timer -= delta

func _apply_gravity(delta: float) -> void:
	var gravity_vector: Vector3 = _gravity_direction * _gravity_strength
	
	if not is_on_floor():
		_velocity += gravity_vector * delta
		_velocity = _velocity.limit_length(max_fall_speed)
	else:
		# Project velocity onto floor plane to prevent sliding on slopes
		var floor_normal: Vector3 = get_floor_normal()
		_velocity = _velocity.slide(floor_normal)
		# Cancel gravity component along floor normal
		_velocity -= floor_normal * max(_velocity.dot(floor_normal), 0.0)

func _handle_movement(delta: float) -> void:
	if _input_vector == Vector2.ZERO:
		_apply_friction(delta)
		return
	
	var current_acceleration: float = acceleration if is_on_floor() else air_acceleration
	var target_speed: float = sprint_speed if _is_sprinting else walk_speed
	
	# Get movement basis relative to camera (or gravity-aligned forward)
	var basis: Basis = _get_movement_basis()
	var input_direction: Vector3 = (basis * Vector3(_input_vector.x, 0, _input_vector.y)).normalized()
	
	var target_velocity: Vector3 = input_direction * target_speed
	
	# Only accelerate in horizontal plane relative to gravity
	var horizontal_velocity: Vector3 = _project_on_plane(_velocity, _gravity_direction)
	var horizontal_target: Vector3 = _project_on_plane(target_velocity, _gravity_direction)
	
	horizontal_velocity = horizontal_velocity.lerp(horizontal_target, current_acceleration * delta)
	
	# Preserve vertical velocity component
	var vertical_velocity: Vector3 = _velocity - _project_on_plane(_velocity, _gravity_direction)
	_velocity = horizontal_velocity + vertical_velocity

func _apply_friction(delta: float) -> void:
	if not is_on_floor():
		return
	
	var horizontal_velocity: Vector3 = _project_on_plane(_velocity, _gravity_direction)
	var friction_factor: float = max(1.0 - friction * delta, 0.0)
	horizontal_velocity *= friction_factor
	
	var vertical_velocity: Vector3 = _velocity - _project_on_plane(_velocity, _gravity_direction)
	_velocity = horizontal_velocity + vertical_velocity

func _handle_jump() -> void:
	var can_jump: bool = _coyote_timer > 0.0 && _jump_buffer_timer > 0.0
	
	if can_jump:
		_velocity += -_gravity_direction * jump_velocity
		_coyote_timer = 0.0
		_jump_buffer_timer = 0.0

func _check_fall_recovery() -> void:
	if global_position.dot(_gravity_direction) < fall_death_height:
		_request_reset()

func _request_reset() -> void:
	fell_out_of_world.emit(reset_position)
	global_position = reset_position
	_velocity = Vector3.ZERO
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0

func _get_movement_basis() -> Basis:
	# Use camera controller's horizontal rotation for movement direction
	if _camera_controller:
		return _camera_controller.get_movement_basis()
	
	# Fallback: construct basis from gravity direction
	var forward: Vector3 = -_gravity_direction
	forward = Vector3(forward.x, 0, forward.z).normalized()
	if forward == Vector3.ZERO:
		forward = Vector3.FORWARD
	var right: Vector3 = forward.cross(_gravity_direction).normalized()
	return Basis(right, _gravity_direction, -forward)

func _project_on_plane(vector: Vector3, plane_normal: Vector3) -> Vector3:
	return vector - plane_normal * vector.dot(plane_normal)

## PUBLIC API FOR GRAVITY SHIFT SUBSYSTEM

func set_gravity_direction(direction: Vector3) -> void:
	"""Called by Gravity Shift subsystem to change gravity direction.
	direction must be normalized. Example: Vector3.UP for inverted gravity."""
	if direction == Vector3.ZERO:
		push_error("Gravity direction cannot be zero vector")
		return
	
	direction = direction.normalized()
	
	if _gravity_direction == direction:
		return
	
	_gravity_direction = direction
	_gravity_strength = base_gravity
	
	# Reorient velocity to new gravity plane
	_velocity = _project_on_plane(_velocity, _gravity_direction)
	
	# Notify camera controller for smooth transition
	if _camera_controller:
		_camera_controller.on_gravity_changed(_gravity_direction)
	
	gravity_changed.emit(_gravity_direction)

func get_gravity_direction() -> Vector3:
	return _gravity_direction

func get_gravity_strength() -> float:
	return _gravity_strength

func set_gravity_strength(strength: float) -> void:
	_gravity_strength = max(strength, 0.0)

func get_velocity() -> Vector3:
	return _velocity

func is_grounded() -> bool:
	return is_on_floor()

## INPUT ACTIONS REQUIRED (documented for integration owner)
## ================================================================
## move_forward      - W / Up Arrow       - Move forward relative to camera
## move_backward     - S / Down Arrow     - Move backward relative to camera
## move_left         - A / Left Arrow     - Strafe left relative to camera
## move_right        - D / Right Arrow    - Strafe right relative to camera
## sprint            - Left Shift         - Hold to sprint
## jump              - Space              - Jump (with coyote time & buffer)
## toggle_camera     - C                  - Toggle first/third person
## mouse_capture     - Escape             - Release mouse capture
## ================================================================
## These actions must be defined in Project Settings -> Input Map.
## The integration owner is responsible for adding them to project.godot.