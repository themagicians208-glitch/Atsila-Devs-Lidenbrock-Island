extends AnimatableBody3D
class_name MovingPlatform

## A solid platform that patrols between its spawn point and spawn + move_offset.
## Used to bridge wide gaps so the player has to time their jumps.

@export var move_offset := Vector3(3.0, 0.0, 0.0)
@export var speed := 1.2

var _origin := Vector3.ZERO
var _phase := 0.0
var _started := false


func _ready() -> void:
	_origin = position
	sync_to_physics = true


func _physics_process(delta: float) -> void:
	if not _started:
		# Defer until the first physics tick so _origin is the placed position.
		_origin = position
		_started = true
	_phase += delta * speed
	var t := (sin(_phase) + 1.0) * 0.5
	position = _origin + move_offset * t