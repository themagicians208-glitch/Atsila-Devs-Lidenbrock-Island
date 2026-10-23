extends Area3D
class_name ExitDoor

signal unlocked
signal level_completed(level_id: String, score: int, time: float)
@export var locked := true
var _completed := false

func _ready() -> void:
	add_to_group("level_exit_door")
	body_entered.connect(_on_body_entered)
	_update_visual()

func unlock() -> void:
	if not locked:
		return
	var plate := get_tree().get_first_node_in_group("puzzle_pressure_plate")
	if not plate or not plate.is_active:
		return
	locked = false
	_update_visual()
	unlocked.emit()

func lock() -> void:
	if _completed:
		return
	locked = true
	_update_visual()

func _on_body_entered(body: Node3D) -> void:
	if locked or _completed or not (body.is_in_group("player") or body.name == "Player"):
		return
	_completed = true
	_update_visual()
	var score := 0
	var manager := get_node_or_null("/root/ScoreManager")
	if manager:
		score = manager.get_score()
	var time := 0.0
	var level_manager := get_node_or_null("/root/LevelManager")
	if level_manager:
		time = level_manager.get_elapsed_time()
		level_manager.level_completed.emit("level_01", score, time)
	level_completed.emit("level_01", score, time)

func reset_puzzle() -> void:
	locked = true
	_completed = false
	_update_visual()

func _update_visual() -> void:
	var mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
	if not mesh:
		return
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("ef4444") if locked else Color("22c55e")
	material.emission_enabled = true
	material.emission = material.albedo_color * 0.35
	mesh.material_override = material

