extends Area3D
class_name PuzzleCollectible

signal collected(value: int)
@export var value := 100
@export var collectible_id := ""
var _collected := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var manager := get_node_or_null("/root/ScoreManager")
	if manager and collectible_id != "":
		manager.register_collectible(collectible_id, value)

func _on_body_entered(body: Node3D) -> void:
	if _collected or not (body.is_in_group("player") or body.name == "Player"):
		return
	_collected = true
	var manager := get_node_or_null("/root/ScoreManager")
	if manager and collectible_id != "":
		manager.collect(collectible_id)
	collected.emit(value)
	visible = false
	monitoring = false

func reset_puzzle() -> void:
	_collected = false
	visible = true
	monitoring = true

