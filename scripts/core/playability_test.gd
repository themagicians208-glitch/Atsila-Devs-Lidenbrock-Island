extends Node

var _frame_count: int = 0
var _player: Node3D = null
var _max_frames: int = 500
var _min_y: float = INF
var _max_y: float = -INF
var _ground_top_y: float = 0.0
var _landed: bool = false
var _landed_frame: int = 0
var _post_land_min_y: float = INF
var _post_land_max_y: float = -INF

func _ready() -> void:
	call_deferred("_init_test")

func _init_test() -> void:
	var main = get_tree().current_scene
	if main and main.has_node("Player"):
		_player = main.get_node("Player")
		
		if main.has_node("LevelInstance"):
			var level = main.get_node("LevelInstance")
			var ground = level.find_child("Ground", true, false)
			if ground:
				# Ground is StaticBody3D at (0, -0.5, 0) with BoxShape3D size (50, 1, 50)
				# BoxShape3D is centered, so extends from -0.5 to +0.5 in local Y
				# World top = ground.global_position.y + 0.5
				_ground_top_y = ground.global_position.y + 0.5
		
		print("PLAYABILITY TEST STARTED")
		print("Ground top surface Y (calculated): ", _ground_top_y)
		print("Spawn marker Y: ", _get_spawn_y(main))
		print("Player collision: CapsuleShape3D radius=0.5 height=1.8 (total=2.8, half=1.4)")
		print("Expected player Y on ground: ", _ground_top_y + 1.4)
	
	set_process(true)

func _get_spawn_y(main: Node) -> float:
	var level = main.get_node_or_null("LevelInstance")
	if level:
		var spawn = level.find_child("player_spawn", true, false)
		if spawn:
			return spawn.global_position.y
	return 0.0

func _process(delta: float) -> void:
	if not _player:
		return
	
	_frame_count += 1
	var y = _player.global_position.y
	var on_floor = _player.is_on_floor()
	_min_y = min(_min_y, y)
	_max_y = max(_max_y, y)
	
	if on_floor and not _landed:
		_landed = true
		_landed_frame = _frame_count
		print("Player landed at frame ", _frame_count, " Y = ", y)
	
	if _landed:
		_post_land_min_y = min(_post_land_min_y, y)
		_post_land_max_y = max(_post_land_max_y, y)
	
	if _frame_count <= 10 or _frame_count % 100 == 0:
		print("Frame %d: Player Y = %.3f, Velocity Y = %.3f, OnFloor = %s" % [
			_frame_count, y, _player.velocity.y, str(on_floor)
		])
	
	if _frame_count >= _max_frames:
		_report_results()
		get_tree().quit()

func _report_results() -> void:
	print("\n=== PLAYABILITY TEST RESULTS ===")
	print("Frames simulated: ", _frame_count)
	print("Ground top Y: ", _ground_top_y)
	print("Landed at frame: ", _landed_frame)
	print("Post-land Min Y: ", _post_land_min_y)
	print("Post-land Max Y: ", _post_land_max_y)
	print("Post-land variance: ", _post_land_max_y - _post_land_min_y)
	print("Final OnFloor: ", _player.is_on_floor())
	print("Final Velocity Y: ", _player.velocity.y)
	
	# Condition 1: Never fell through ground (min Y > ground_top - small epsilon)
	var epsilon = 0.1
	var cond1_never_fell_through = _min_y > _ground_top_y - epsilon
	print("\n--- ACCEPTANCE CONDITIONS ---")
	print("1. Never fell through ground: ", cond1_never_fell_through)
	print("   Min Y (%.3f) > Ground Top Y - %.1f (%.3f)" % [_min_y, epsilon, _ground_top_y - epsilon])
	
	# Condition 2: Player landed (on_floor became true at some point)
	var cond2_landed = _landed
	print("2. Player landed: ", cond2_landed)
	print("   Landed frame: ", _landed_frame)
	
	# Condition 3: Stable after landing (variance < 0.1)
	var cond3_stable = (_post_land_max_y - _post_land_min_y) < 0.1
	print("3. Stable after landing: ", cond3_stable)
	print("   Post-land variance: %.6f < 0.1" % (_post_land_max_y - _post_land_min_y))
	
	var all_pass = cond1_never_fell_through and cond2_landed and cond3_stable
	print("\n=== FINAL RESULT ===")
	if all_pass:
		print("TEST PASSED - All conditions met")
	else:
		print("TEST FAILED")
		if not cond1_never_fell_through:
			print("  FAILED: Condition 1 - Player fell through ground")
		if not cond2_landed:
			print("  FAILED: Condition 2 - Player never landed")
		if not cond3_stable:
			print("  FAILED: Condition 3 - Player unstable after landing")
