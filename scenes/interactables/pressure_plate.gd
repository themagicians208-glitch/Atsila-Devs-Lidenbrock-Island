extends StaticBody3D

signal activated(activator: Node3D)
signal deactivated
var is_active := false
var _activator: Node3D
var _bodies_on_plate: Dictionary = {}

func _ready() -> void:
	add_to_group("puzzle_pressure_plate")
	$Detection.body_entered.connect(_on_body_entered)
	$Detection.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if not _is_valid_activator(body):
		return
	var body_id := body.get_instance_id()
	if _bodies_on_plate.has(body_id):
		return
	_bodies_on_plate[body_id] = body
	if is_active:
		return
	is_active = true
	_activator = body
	activated.emit(body)
	var door := get_tree().get_first_node_in_group("level_exit_door")
	if door and door.has_method("unlock"):
		door.unlock()
	var hud := get_node_or_null("/root/Main/HUD")
	if hud and hud.has_method("update_objective"):
		hud.update_objective("Objective: reach the open exit")

func _on_body_exited(body: Node3D) -> void:
	var body_id := body.get_instance_id()
	if not _bodies_on_plate.erase(body_id):
		return
	if not _bodies_on_plate.is_empty():
		return
	is_active = false
	_activator = null
	deactivated.emit()
	var door := get_tree().get_first_node_in_group("level_exit_door")
	if door and door.has_method("lock"):
		door.lock()

func reset_puzzle() -> void:
	is_active = false
	_activator = null
	_bodies_on_plate.clear()
	var door := get_tree().get_first_node_in_group("level_exit_door")
	if door and door.has_method("lock"):
		door.lock()

func _is_player(body: Node3D) -> bool:
	return body.is_in_group("player") or body.name == "Player"

func _is_valid_activator(body: Node3D) -> bool:
	return _is_player(body) or (body is RigidBody3D and body.is_in_group("puzzle_interactable"))

