extends Node3D
class_name SeeSaw

## A tipping see-saw. The plank tilts toward whichever end the player stands on,
## so the player has to keep moving or slide toward the middle.

@export var max_tilt_degrees := 22.0
@export var tilt_speed := 5.0

var _plank: AnimatableBody3D
var _target: Node3D


func configure(plank: AnimatableBody3D, target: Node3D) -> void:
	_plank = plank
	_target = target


func _physics_process(delta: float) -> void:
	if _plank == null or _target == null or not is_instance_valid(_target):
		return
	var local := to_local(_target.global_position)
	var limit := deg_to_rad(max_tilt_degrees)
	var desired := 0.0
	if absf(local.x) < 1.1 and local.y > -1.5 and local.y < 2.6 and absf(local.z) > 0.4:
		desired = clampf(signf(local.z) * limit, -limit, limit)
	_plank.rotation.x = lerp_angle(_plank.rotation.x, desired, delta * tilt_speed)