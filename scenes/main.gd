extends Node3D

var level_instance: Node3D
var player: Node3D
var hud: CanvasLayer
var pause_menu: CanvasLayer
var victory_screen: CanvasLayer

var _score_manager
var _level_manager
var _spawn_requested: bool = false

func _ready() -> void:
	level_instance = get_node("LevelInstance")
	player = get_node("Player")
	hud = get_node("HUD")
	pause_menu = get_node("PauseMenu")
	victory_screen = get_node("VictoryScreen")
	
	_score_manager = get_node("/root/ScoreManager")
	_level_manager = get_node("/root/LevelManager")
	
	pause_menu.visible = false
	victory_screen.visible = false
	
	# Connect pause menu signals
	pause_menu.resume_requested.connect(_on_resume_requested)
	pause_menu.restart_requested.connect(_on_restart_requested)
	pause_menu.quit_requested.connect(_on_quit_requested)
	
	# Connect victory screen
	victory_screen.victory_confirmed.connect(_on_victory_confirmed)
	
	# Connect level manager
	_level_manager.level_completed.connect(_on_level_completed)
	_level_manager.level_restarted.connect(_on_level_restarted)
	
	# Position player at spawn point (deferred to ensure scene is ready)
	call_deferred("_position_player_at_spawn")
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _position_player_at_spawn() -> void:
	if not is_inside_tree():
		return
	var active_scene := get_tree().current_scene
	if not active_scene or not active_scene.is_inside_tree():
		return
	var active_level := active_scene.get_node_or_null("LevelInstance")
	var active_player := active_scene.get_node_or_null("Player")
	if not active_level or not active_player or not active_player.is_inside_tree():
		return
	var spawn_marker = active_level.find_child("player_spawn", true, false)
	if spawn_marker and spawn_marker is Marker3D:
		active_player.global_position = spawn_marker.global_position
		active_player.global_rotation = spawn_marker.global_rotation
		# Reset velocity to prevent momentum from previous session
		active_player.velocity = Vector3.ZERO

func _on_resume_requested() -> void:
	pause_menu.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false

func _on_restart_requested() -> void:
	pause_menu.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	hud.show_failure_message("RESTARTING LEVEL...")
	_level_manager.restart_current()

func _on_quit_requested() -> void:
	get_tree().quit()

func _on_victory_confirmed() -> void:
	victory_screen.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# TODO: Load next level when available
	# _level_manager.load_level("level_02")

func _on_level_completed(level_id: String, score: int, time: float) -> void:
	var found = _score_manager.get_collectibles_found()
	var total = _score_manager.get_collectibles_total()
	victory_screen.show_victory(score, time, found, total)
	victory_screen.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

func _on_level_restarted(level_id: String) -> void:
	# Use call_deferred to ensure the new scene is fully instantiated before positioning
	call_deferred("_position_player_at_spawn")
	call_deferred("_show_respawn_message")
	_score_manager.reset()

func _show_respawn_message() -> void:
	# Restart emits before the old Main leaves the tree; its deferred callback may run after teardown.
	if not is_inside_tree():
		return
	var active_scene := get_tree().current_scene
	if not active_scene or not active_scene.is_inside_tree():
		return
	var active_hud := active_scene.get_node_or_null("HUD")
	if active_hud and active_hud.has_method("show_failure_message"):
		active_hud.show_failure_message("RESPAWNING...")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not victory_screen.visible:
		_toggle_pause()
	elif event.is_action_pressed("restart") and not pause_menu.visible and not victory_screen.visible:
		hud.show_failure_message("RESTARTING LEVEL...")
		_level_manager.restart_current()

func _toggle_pause() -> void:
	if get_tree().paused:
		_on_resume_requested()
	else:
		pause_menu.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
