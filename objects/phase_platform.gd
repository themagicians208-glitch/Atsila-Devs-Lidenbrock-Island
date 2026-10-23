extends AnimatableBody3D
class_name PhasePlatform

## A platform that blinks in and out of existence. It is solid only while
## active, so the player has to cross during the window when it is lit.

@export var on_duration := 2.0
@export var off_duration := 1.8
@export var start_on := true

var _timer := 0.0
var _active := true
var _shapes: Array[CollisionShape3D] = []


func _ready() -> void:
	sync_to_physics = true
	for child in find_children("*", "CollisionShape3D", true, false):
		_shapes.append(child as CollisionShape3D)
	_apply(start_on)


func _physics_process(delta: float) -> void:
	_timer += delta
	if _active and _timer >= on_duration:
		_timer = 0.0
		_apply(false)
	elif not _active and _timer >= off_duration:
		_timer = 0.0
		_apply(true)


func _apply(state: bool) -> void:
	_active = state
	visible = state
	for shape in _shapes:
		shape.set_deferred("disabled", not state)