extends RigidBody3D
class_name PhysicsCrate

signal interaction_feedback(message: String)

@export var target_position := Vector3(0, 1.0, -18)
var _interacting := false
var _solved := false
var _initial_transform: Transform3D
var _gravity_source: Node

func _ready() -> void:
	_initial_transform = global_transform
	add_to_group("puzzle_interactable")
	var hud := get_node_or_null("/root/Main/HUD")
	if hud and hud.has_method("update_objective"):
		hud.update_objective("Objective: link the corrupted crate, then use Gravity Shift to place it on the plate")

func can_interact(interactor: Node3D) -> bool:
	return not _solved and not _interacting and is_instance_valid(interactor) and global_position.distance_to(interactor.global_position) < 4.0

func interact(interactor: Node3D) -> void:
	if not can_interact(interactor):
		return
	_interacting = true
	freeze = true
	if interactor.has_signal("gravity_shifted"):
		_gravity_source = interactor
		_gravity_source.gravity_shifted.connect(_on_gravity_shifted)
	else:
		_publish_feedback("Gravity integration is unavailable: Player.gravity_shifted(new_gravity) is required.")
	_publish_feedback("Crate linked. Use Gravity Shift to move it onto the plate.")

func get_prompt() -> String:
	return "Press E to link corrupted crate" if not _interacting else "Gravity Shift to solve"

func apply_gravity_shift(new_gravity: Vector3) -> void:
	if not _interacting or _solved:
		return
	if new_gravity.normalized() != Vector3.UP:
		_publish_feedback("The crate needs inverted gravity.")
		return
	global_position = target_position
	_solved = true
	_interacting = false
	freeze = false
	linear_velocity = Vector3.ZERO
	_publish_feedback("Gravity aligned. The crate is on the pressure plate.")

func _on_gravity_shifted(new_gravity: Vector3) -> void:
	apply_gravity_shift(new_gravity)

func reset_puzzle() -> void:
	global_transform = _initial_transform
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	freeze = false
	_interacting = false
	_solved = false
	if is_instance_valid(_gravity_source) and _gravity_source.gravity_shifted.is_connected(_on_gravity_shifted):
		_gravity_source.gravity_shifted.disconnect(_on_gravity_shifted)
	_gravity_source = null

func _publish_feedback(message: String) -> void:
	interaction_feedback.emit(message)
	var hud := get_node_or_null("/root/Main/HUD")
	if hud and hud.has_method("show_interaction_prompt"):
		hud.show_interaction_prompt(message)

