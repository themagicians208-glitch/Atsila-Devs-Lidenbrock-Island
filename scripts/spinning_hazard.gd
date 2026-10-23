extends AnimatableBody3D

@export var spin_speed := 1.25


func _process(delta: float) -> void:
	rotation.y += spin_speed * delta
