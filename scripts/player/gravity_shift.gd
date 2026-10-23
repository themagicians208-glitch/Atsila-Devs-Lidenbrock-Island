class_name GravityShift

signal gravity_changed(new_gravity: Vector3)

var _owner: CharacterBody3D = null
var _player: Node = null
var _cooldown: float = 1.5
var _cooldown_timer: float = 0.0
var _gravity_directions: Array[Vector3] = [
	Vector3(0, -9.8, 0),   # Down (normal)
	Vector3(0, 9.8, 0),    # Up (inverted)
	Vector3(9.8, 0, 0),    # Right
	Vector3(-9.8, 0, 0),   # Left
	Vector3(0, 0, 9.8),    # Forward
	Vector3(0, 0, -9.8)    # Back
]
var _current_gravity_index: int = 0

func init(owner: CharacterBody3D) -> void:
	_owner = owner
	_player = owner
	# Try to get active gravity zone
	var zone = _find_active_gravity_zone()
	if zone:
		_gravity_directions = zone.get_allowed_directions()

func _find_active_gravity_zone() -> Object:
	var zones = _player.get_tree().get_nodes_in_group("gravity_zones")
	for zone in zones:
		if zone.has_method("get_allowed_directions"):
			return zone
	return null

func request_shift() -> void:
	if _cooldown_timer > 0.0:
		return
	
	_current_gravity_index = (_current_gravity_index + 1) % _gravity_directions.size()
	var new_gravity = _gravity_directions[_current_gravity_index]
	
	_apply_gravity_shift(new_gravity)
	_cooldown_timer = _cooldown

func _apply_gravity_shift(new_gravity: Vector3) -> void:
	if not _owner:
		return
	
	# Apply through the CharacterBody3D movement API.
	if _owner.has_method("apply_gravity_shift"):
		_owner.apply_gravity_shift(new_gravity)
	else:
		return
	
	# Apply to all gravity-affected bodies in active zone
	var zone = _find_active_gravity_zone()
	if zone:
		for body in zone._bodies_inside:
			if body and body.has_method("apply_gravity_shift"):
				body.apply_gravity_shift(new_gravity)
	
	gravity_changed.emit(new_gravity)

func _physics_process(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta
	
	# Update gravity directions if zone changed
	var zone = _find_active_gravity_zone()
	if zone and zone.get_allowed_directions() != _gravity_directions:
		_gravity_directions = zone.get_allowed_directions()
		_current_gravity_index = 0
