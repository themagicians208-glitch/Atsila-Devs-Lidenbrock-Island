extends CharacterBody3D
class_name Player

# Signals
signal gravity_shifted(new_gravity: Vector3)
signal interact_target_changed(target)
signal collectible_picked_up(value: int)

# Components
var pivot: Node3D
var camera: Camera3D
var interact_raycast: RayCast3D
var gravity_shift_effect: GPUParticles3D
var camera_controller: CameraController
var movement
var gravity_shift
var _level_manager

# State
var _current_interact_target = null
var _current_gravity: Vector3 = Vector3(0, -9.8, 0)
var _gravity_zones: Array[Object] = []
var _active_zone: Object = null

func _ready() -> void:
	camera_controller = get_node("CameraController")
	camera = camera_controller.get_camera()
	interact_raycast = camera.get_node("InteractRaycast")
	gravity_shift_effect = get_node("CameraController/FPPivot/GravityShiftEffect")
	
	movement = preload("res://scripts/player/player_movement.gd").new()
	gravity_shift = preload("res://scripts/player/gravity_shift.gd").new()
	_level_manager = get_node("/root/LevelManager")
	
	movement.init(self)
	gravity_shift.init(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_to_group("player")
	
	# Connect gravity shift
	gravity_shift.gravity_changed.connect(_on_gravity_changed)
	gravity_shifted.connect(camera_controller.on_gravity_changed)
	
	# Start with default gravity
	_current_gravity = Vector3(0, -ProjectSettings.get_setting("physics/3d/default_gravity"), 0)
	movement.set_gravity(_current_gravity)

func _physics_process(delta: float) -> void:
	movement.update(delta)
	_check_interactable()
	_check_void_death()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("gravity_shift"):
		gravity_shift.request_shift()
	elif event.is_action_pressed("interact"):
		_try_interact()
	elif event.is_action_pressed("jump"):
		movement.handle_jump_input()

func _check_interactable() -> void:
	var target = null
	if interact_raycast.is_colliding():
		var collider = interact_raycast.get_collider()
		if collider and collider.has_method("can_interact") and collider.can_interact(self):
			target = collider
	
	if target != _current_interact_target:
		_current_interact_target = target
		interact_target_changed.emit(target)

func _try_interact() -> void:
	if _current_interact_target:
		_current_interact_target.interact(self)

func _on_gravity_changed(new_gravity: Vector3) -> void:
	_current_gravity = new_gravity
	gravity_shifted.emit(new_gravity)
	
	# Visual feedback
	gravity_shift_effect.emitting = true
	
	# Camera reorientation (smooth)
	var target_up = -new_gravity.normalized()
	var current_up = -_current_gravity.normalized()
	if target_up != current_up:
		var tween = create_tween()
		tween.tween_property(pivot, "rotation", _calculate_camera_rotation(target_up), 0.3)
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)

func _calculate_camera_rotation(up: Vector3) -> Vector3:
	# Simplified: just return current rotation, camera reorientation handled by pivot
	return pivot.rotation

func _check_void_death() -> void:
	if global_position.y < -50:
		_level_manager.restart_current()

func get_camera() -> Camera3D:
	return camera

func get_movement_state() -> Dictionary:
	return {
		"velocity": velocity,
		"is_on_floor": is_on_floor(),
		"gravity_dir": _current_gravity.normalized()
	}

func request_gravity_shift() -> void:
	gravity_shift.request_shift()

func add_gravity_zone(zone: Object) -> void:
	if zone not in _gravity_zones:
		_gravity_zones.append(zone)
		if not _active_zone:
			_active_zone = zone

func remove_gravity_zone(zone: Object) -> void:
	_gravity_zones.erase(zone)
	if _active_zone == zone:
		_active_zone = _gravity_zones[0] if _gravity_zones.size() > 0 else null

func get_active_zone() -> Object:
	return _active_zone

func apply_gravity_shift(new_gravity: Vector3) -> void:
	_current_gravity = new_gravity
	movement.set_gravity(new_gravity)
