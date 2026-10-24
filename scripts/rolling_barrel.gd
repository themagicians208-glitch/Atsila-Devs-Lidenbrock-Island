extends AnimatableBody3D
class_name RollingBarrel

## A barrel that rolls back and forth along the path, sweeping into the player.

@export var move_offset := Vector3(0.0, 0.0, 4.0)
@export var move_speed := 1.2
@export var roll_speed := 4.0

var _origin := Vector3.ZERO
var _phase := 0.0
var _started := false


func _ready() -> void:
	# Rotation is node-driven here, so don't let physics own the transform.
	sync_to_physics = false


func _physics_process(delta: float) -> void:
	if not _started:
		_origin = position
		_started = true
	_phase += delta * move_speed
	position = _origin + move_offset * ((sin(_phase) + 1.0) * 0.5)
	rotate_x(roll_speed * delta)