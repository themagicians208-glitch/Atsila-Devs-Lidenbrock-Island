extends SceneTree

class TestPlayer extends CharacterBody3D:
	signal gravity_shifted(new_gravity: Vector3)

## Isolated contract test: uses production puzzle scenes/scripts but calls signals directly.
## It does not replace a playtest of the complete Level 1 scene.
func _init() -> void:
	var level_scene := load("res://scenes/levels/level_01_broken_shore.tscn") as PackedScene
	assert(level_scene != null)

	var score_manager: Node = load("res://scripts/core/score_manager.gd").new()
	score_manager.name = "ScoreManager"
	root.add_child(score_manager)

	var door_scene := load("res://scenes/interactables/exit_door.tscn") as PackedScene
	var door := door_scene.instantiate() as Area3D
	root.add_child(door)

	var plate_scene := load("res://scenes/interactables/pressure_plate.tscn") as PackedScene
	var plate := plate_scene.instantiate() as StaticBody3D
	plate.name = "PressurePlate_01"
	root.add_child(plate)
	await process_frame

	var crate_scene := load("res://scenes/interactables/physics_crate.tscn") as PackedScene
	var crate := crate_scene.instantiate() as RigidBody3D
	crate.name = "PhysicsCrate_01"
	root.add_child(crate)
	await process_frame

	var player := TestPlayer.new()
	player.name = "Player"
	root.add_child(player)
	player.global_position = crate.global_position
	assert(crate.can_interact(player))
	crate.interact(player)
	player.emit_signal("gravity_shifted", Vector3.DOWN)
	assert(crate.global_position != crate.target_position)
	player.emit_signal("gravity_shifted", Vector3.UP)
	assert(crate.global_position == crate.target_position)

	var activations: Array[Node3D] = []
	plate.activated.connect(func(body: Node3D): activations.append(body))
	plate._on_body_entered(crate)
	plate._on_body_entered(player)
	assert(plate.is_active)
	assert(activations.size() == 1)
	plate._on_body_exited(crate)
	assert(plate.is_active)
	plate._on_body_exited(player)
	assert(not plate.is_active)
	assert(door.locked)

	plate._on_body_entered(crate)
	assert(door.locked == false)
	var completions: Array[String] = []
	door.level_completed.connect(func(level_id: String, _score: int, _time: float): completions.append(level_id))
	door._on_body_entered(player)
	door._on_body_entered(player)
	assert(completions == ["level_01"])

	var collectible_scene := load("res://scenes/interactables/collectible.tscn") as PackedScene
	var collectible := collectible_scene.instantiate() as Area3D
	root.add_child(collectible)
	await process_frame
	collectible._on_body_entered(player)
	collectible._on_body_entered(player)
	assert(score_manager.get_score() == 100)
	assert(not collectible.visible)

	print("PASS: production puzzle scenes loaded; gravity signal, plate overlap, exit guard, and collectible idempotence")
	quit()

