extends CharacterBody3D

class_name PlayerController

@export_group("Movement")
@export var move_speed: float = 6.0
@export var jump_velocity: float = 8.0
@export var air_acceleration: float = 0.5
@export var ground_acceleration: float = 10.0

@export_group("Gravity")
@export var gravity: float = 20.0

@export_group("Camera")
@export var mouse_sensitivity: float = 0.002
@export var camera_distance: float = 5.0

var _gravity_component: GravityShiftComponent
var _camera: Camera3D
var _input_dir: Vector2 = Vector2.ZERO
var _target_velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	_gravity_component = get_node_or_null("GravityShiftComponent")
	_camera = get_node_or_null("Camera3D")
	
	if _camera:
		_camera.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	if not _gravity_component:
		return
	
	var is_reversed = _gravity_component.is_gravity_reversed()
	var up_dir = _gravity_component.get_up_direction()
	
	_handle_input()
	_handle_movement(delta, up_dir)
	_handle_jump(up_dir)
	
	move_and_slide()

func _handle_input() -> void:
	_input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		_input_dir.y -= 1
	if Input.is_action_pressed("move_backward"):
		_input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		_input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		_input_dir.x += 1
	_input_dir = _input_dir.normalized()

func _handle_movement(delta: float, up_dir: Vector3) -> void:
	var forward = -_camera.global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()
	
	var right = _camera.global_transform.basis.x
	right.y = 0
	right = right.normalized()
	
	var wish_dir = (forward * _input_dir.y + right * _input_dir.x).normalized()
	var wish_speed = move_speed
	
	var accel = ground_acceleration if is_on_floor() else air_acceleration
	_target_velocity = velocity.lerp(wish_dir * wish_speed, accel * delta)
	
	velocity.x = _target_velocity.x
	velocity.z = _target_velocity.z

func _handle_jump(up_dir: Vector3) -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity += up_dir * jump_velocity

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _camera:
		rotate_y(-event.relative.x * mouse_sensitivity)
		_camera.rotate_x(-event.relative.y * mouse_sensitivity)
		_camera.rotation.x = clamp(_camera.rotation.x, -PI/2, PI/2)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true