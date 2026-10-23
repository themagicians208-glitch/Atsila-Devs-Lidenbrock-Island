class_name PlayerMovement

var _owner: CharacterBody3D = null
var _pivot: Node3D = null
var _camera: Camera3D = null

# Movement settings
const MOVE_SPEED = 6.0
const JUMP_VELOCITY = 8.5
const GRAVITY = 9.8
const ACCELERATION = 20.0
const DECELERATION = 25.0
const AIR_ACCELERATION = 5.0
const AIR_DECELERATION = 2.0
const MOUSE_SENSITIVITY = 0.002
const MAX_VERTICAL_ANGLE = deg_to_rad(85)

# State
var _velocity: Vector3 = Vector3.ZERO
var _input_dir: Vector3 = Vector3.ZERO
var _target_velocity: Vector3 = Vector3.ZERO
var _vertical_velocity: float = 0.0
var _is_on_floor: bool = false
var _coyote_time: float = 0.0
const COYOTE_TIME_MAX = 0.1
var _jump_buffer: float = 0.0
const JUMP_BUFFER_MAX = 0.15
var _gravity_direction: Vector3 = Vector3.DOWN
var _gravity_strength: float = GRAVITY

func init(owner: CharacterBody3D) -> void:
	_owner = owner
	_pivot = owner.get_node_or_null("Pivot")
	_camera = owner.get_node_or_null("Pivot/Camera3D")
	_owner.up_direction = Vector3.UP

func set_gravity(new_gravity: Vector3) -> void:
	if new_gravity.is_zero_approx():
		return
	_gravity_strength = new_gravity.length()
	_gravity_direction = new_gravity.normalized()
	_owner.up_direction = -_gravity_direction
	_owner.velocity = _project_on_plane(_owner.velocity, _gravity_direction)

func update(delta: float) -> void:
	_is_on_floor = _owner.is_on_floor()
	
	# Handle coyote time
	if _is_on_floor:
		_coyote_time = COYOTE_TIME_MAX
	else:
		_coyote_time -= delta
	
	# Handle jump buffer
	_jump_buffer -= delta
	
	# Get input direction
	_input_dir = _get_input_direction()
	
	# Calculate target velocity on horizontal plane
	var basis = _camera.global_transform.basis if _camera else _owner.global_transform.basis
	var forward = -basis.z
	var right = basis.x
	
	# Project movement onto the plane perpendicular to gravity.
	var gravity_dir = _gravity_direction
	var gravity_up = -gravity_dir
	
	forward = (forward - gravity_up * forward.dot(gravity_up)).normalized()
	right = (right - gravity_up * right.dot(gravity_up)).normalized()
	
	_target_velocity = (forward * _input_dir.z + right * _input_dir.x) * MOVE_SPEED
	
	# Horizontal acceleration/deceleration
	var horiz_vel = _project_on_plane(_owner.velocity, gravity_dir)
	var target_horiz = _project_on_plane(_target_velocity, gravity_dir)
	var accel = ACCELERATION if _is_on_floor else AIR_ACCELERATION
	var decel = DECELERATION if _is_on_floor else AIR_DECELERATION
	
	if target_horiz.length() > 0.01:
		horiz_vel = horiz_vel.lerp(target_horiz, accel * delta)
	else:
		horiz_vel = horiz_vel.lerp(Vector3.ZERO, decel * delta)
	
	# Gravity-axis velocity
	_vertical_velocity = _owner.velocity.dot(gravity_dir)
	
	# Jump
	if _jump_buffer > 0 and _coyote_time > 0:
		_vertical_velocity = -JUMP_VELOCITY
		_jump_buffer = 0
		_coyote_time = 0
	
	# Apply gravity
	_vertical_velocity += _gravity_strength * delta
	
	# Combine
	_owner.velocity = horiz_vel + gravity_dir * _vertical_velocity
	_owner.move_and_slide()

func _project_on_plane(vector: Vector3, normal: Vector3) -> Vector3:
	return vector - normal * vector.dot(normal)

func _get_input_direction() -> Vector3:
	var dir = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		dir.z -= 1
	if Input.is_action_pressed("move_backward"):
		dir.z += 1
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1
	return dir.normalized() if dir.length() > 0 else Vector3.ZERO

func process_mouse_motion(event: InputEventMouseMotion) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	# Horizontal rotation (yaw) on body
	_owner.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
	
	# Vertical rotation (pitch) on pivot
	if _pivot:
		var new_rot_x = _pivot.rotation.x - event.relative.y * MOUSE_SENSITIVITY
		new_rot_x = clamp(new_rot_x, -MAX_VERTICAL_ANGLE, MAX_VERTICAL_ANGLE)
		_pivot.rotation.x = new_rot_x

func handle_jump_input() -> void:
	_jump_buffer = JUMP_BUFFER_MAX
