extends SceneTree

## Production smoke test: loads main.tscn and uses its real Player and puzzle instances.
## It does not replace a manual playtest of camera/input/physics timing.
func _init() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	for _i in range(6):
		await physics_frame

	var main := current_scene
	assert(main != null)
	var score_manager: Node = root.get_node("ScoreManager")
	var level_manager: Node = root.get_node("LevelManager")
	var player := main.get_node("Player")
	var level := main.get_node("LevelInstance")
	var crate := level.get_node("PuzzleElements/PhysicsCrate_01")
	var plate := level.get_node("PuzzleElements/PressurePlate_01")
	var door := level.get_node("PuzzleElements/ExitDoor_01")
	var collectible := level.get_node("Collectibles/Collectible_01")

	player.global_position = crate.global_position
	assert(crate.can_interact(player))
	crate.interact(player)
	player.request_gravity_shift()
	for _i in range(6):
		await physics_frame
	assert(crate.get("_solved"))
	assert(plate.is_active)
	assert(not door.locked)

	collectible._on_body_entered(player)
	collectible._on_body_entered(player)
	assert(score_manager.get_score() == 100)

	var completions: Array[String] = []
	level_manager.level_completed.connect(func(level_id: String, _score: int, _time: float): completions.append(level_id))
	door._on_body_entered(player)
	door._on_body_entered(player)
	assert(completions == ["level_01"])

	paused = false
	level_manager.restart_current()
	for _i in range(8):
		await process_frame
	assert(score_manager.get_score() == 0)
	var restarted_level := current_scene.get_node("LevelInstance")
	assert(not restarted_level.get_node("PuzzleElements/PressurePlate_01").is_active)
	assert(restarted_level.get_node("PuzzleElements/ExitDoor_01").locked)

	print("PASS: production Level 1 smoke path, gravity, plate, exit, score, and restart")
	quit()

