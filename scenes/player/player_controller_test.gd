extends SceneTree

## Focused controller test. It verifies wiring and state transitions, not subjective mouse feel.
func _init() -> void:
	await process_frame
	for action in ["move_forward", "move_backward", "move_left", "move_right", "jump", "gravity_shift", "interact", "toggle_camera", "mouse_capture", "zoom_in", "zoom_out"]:
		assert(InputMap.has_action(action))
	var scene := load("res://scenes/player/Player.tscn") as PackedScene
	assert(scene != null)
	var player := scene.instantiate()
	root.add_child(player)
	await physics_frame

	var camera_controller := player.get_node("CameraController")
	assert(player.get_camera() == camera_controller.get_camera())
	assert(camera_controller.is_first_person())
	camera_controller.set_first_person(false)
	assert(not camera_controller.is_first_person())
	camera_controller.set_first_person(true)
	assert(camera_controller.is_first_person())

	var mouse_event := InputEventMouseMotion.new()
	mouse_event.relative = Vector2(0, 100000)
	camera_controller._unhandled_input(mouse_event)
	assert(camera_controller.get("_target_pitch") <= deg_to_rad(camera_controller.pitch_limit_max))

	player.apply_gravity_shift(Vector3.UP * 9.8)
	assert(player.up_direction == Vector3.DOWN)
	player.apply_gravity_shift(Vector3.DOWN * 9.8)
	assert(player.up_direction == Vector3.UP)

	print("PASS: Player scene wiring, camera toggle, pitch clamp, and gravity orientation")
	quit()

