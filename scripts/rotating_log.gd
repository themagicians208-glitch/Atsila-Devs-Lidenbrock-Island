extends AnimatableBody3D
class_name RotatingLog

## A log that spins on its axis, acting as a rolling obstacle across the path.

@export var spin_speed := 2.5


func _ready() -> void:
	# Rotation must be node-driven, so do not let the physics server own it.
	sync_to_physics = false


func _physics_process(delta: float) -> void:
	rotate_x(spin_speed * delta)