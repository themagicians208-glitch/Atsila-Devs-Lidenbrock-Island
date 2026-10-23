extends Node3D

const PLATFORM := preload("res://objects/platform.tscn")
const PLATFORM_MEDIUM := preload("res://objects/platform_medium.tscn")
const PLATFORM_GRASS := preload("res://objects/platform_grass_large_round.tscn")
const PLATFORM_FALLING := preload("res://objects/platform_falling.tscn")
const COIN := preload("res://objects/coin.tscn")
const FLAG := preload("res://models/flag.glb")
const GRAVITY_ZONE_SCRIPT := preload("res://scripts/anti_gravity_zone.gd")
const SPINNING_HAZARD_SCRIPT := preload("res://scripts/spinning_hazard.gd")

const LEVEL_NAMES := ["Cloud Hop", "Switchback Sprint", "Moonflip Maze", "Rising Ruins", "Sky Crown"]

@onready var player: CharacterBody3D = $Player
@onready var hud: Control = $HUD
@onready var world: Node3D = $World
@onready var finish: Area3D = $Finish

var current_level := 1
var coin_goal := 0
var puzzle_solved := false
var puzzle_switch: Node3D
var switch_material: StandardMaterial3D
var mirror_dimension := false
var checkpoint_position := Vector3.ZERO
var active_checkpoint := 0


func _ready() -> void:
	Engine.time_scale = 1.0
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Sun.light_color = Color("#fff2d6")
	_ensure_key_action("interact", KEY_E, JOY_BUTTON_X)
	_ensure_key_action("time_freeze", KEY_F, JOY_BUTTON_Y)
	_ensure_key_action("shift_dimension", KEY_Q, JOY_BUTTON_LEFT_SHOULDER, MOUSE_BUTTON_RIGHT)
	current_level = int(get_tree().get_meta("level_number", 1))
	current_level = clampi(current_level, 1, LEVEL_NAMES.size())
	get_tree().set_meta("level_number", current_level)
	_build_level(current_level)
	coin_goal = get_tree().get_nodes_in_group("collectible_coins").size()
	hud.set_coin_goal(coin_goal)
	hud.set_level_info(current_level, LEVEL_NAMES[current_level - 1])
	hud.show_finish_message("RIGHT CLICK / Q / LB: SHIFT DIMENSION")
	hud.continue_pressed.connect(_on_continue_pressed)
	player.coin_collected.connect(_on_coin_collected)
	finish.body_entered.connect(_on_finish_body_entered)
	_build_puzzle_switch()
	_apply_dimension_visibility()
	hud.show_controls_hint()

	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		$Sun.light_energy = 0.24
		$Sun.shadow_opacity = 0.85
		$Environment.environment.background_energy_multiplier = 0.25


func _ensure_key_action(action_name: String, key_code: Key, joy_button: JoyButton, mouse_button: MouseButton = MOUSE_BUTTON_NONE) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
		InputMap.action_set_deadzone(action_name, 0.5)
	var has_key := false
	var has_button := false
	var has_mouse_button := false
	for existing_event in InputMap.action_get_events(action_name):
		if existing_event is InputEventKey and existing_event.physical_keycode == key_code:
			has_key = true
		elif existing_event is InputEventJoypadButton and existing_event.button_index == joy_button:
			has_button = true
		elif existing_event is InputEventMouseButton and existing_event.button_index == mouse_button:
			has_mouse_button = true
	if not has_key:
		var key := InputEventKey.new()
		key.physical_keycode = key_code
		key.device = -1
		InputMap.action_add_event(action_name, key)
	if not has_button:
		var button := InputEventJoypadButton.new()
		button.button_index = joy_button
		button.device = -1
		InputMap.action_add_event(action_name, button)
	if mouse_button != MOUSE_BUTTON_NONE and not has_mouse_button:
		var mouse_event := InputEventMouseButton.new()
		mouse_event.button_index = mouse_button
		mouse_event.device = -1
		InputMap.action_add_event(action_name, mouse_event)


func _build_level(level_number: int) -> void:
	var routes := _get_level_routes()
	var route: Array = routes[level_number - 1]
	for child in world.get_children():
		world.remove_child(child)
		child.free()

	for i in range(route.size()):
		var point: Vector3 = route[i]
		var platform_scene: PackedScene = PLATFORM
		match level_number:
			1:
				if i % 3 == 1:
					platform_scene = PLATFORM_MEDIUM
				elif i % 3 == 2:
					platform_scene = PLATFORM_GRASS
			2:
				if i % 2 == 0:
					platform_scene = PLATFORM_MEDIUM
			3:
				if i % 3 == 0:
					platform_scene = PLATFORM_GRASS
				else:
					platform_scene = PLATFORM_MEDIUM
			4:
				if i % 3 == 1:
					platform_scene = PLATFORM_GRASS
			5:
				if i % 2 == 1:
					platform_scene = PLATFORM_MEDIUM
		if level_number == 1 and i in [3, 6]:
			platform_scene = PLATFORM_FALLING
		elif level_number == 2 and i in [3, 6]:
			platform_scene = PLATFORM_FALLING
		elif level_number == 3 and i in [3, 7]:
			platform_scene = PLATFORM_FALLING
		elif level_number == 4 and i in [3, 6]:
			platform_scene = PLATFORM_FALLING
		elif level_number == 5 and i in [3, 6, 9]:
			platform_scene = PLATFORM_FALLING
		var platform: Node3D = platform_scene.instantiate()
		platform.position = point
		platform.rotation.y = float((i * 23 + level_number * 17) % 50) * PI / 180.0
		platform.add_to_group("material_dimension")
		world.add_child(platform)

		# The mirror path is offset, so shifting dimensions in mid-air creates alternate jumps.
		var mirror_platform: Node3D = PLATFORM_MEDIUM.instantiate()
		mirror_platform.name = "MirrorPlatform_%02d" % i
		mirror_platform.position = _get_mirror_platform_point(route, i)
		mirror_platform.rotation.y = -platform.rotation.y
		mirror_platform.add_to_group("mirror_dimension")
		world.add_child(mirror_platform)
		_add_phase_glow(mirror_platform)

		if i > 0 and i < route.size() - 1:
			var coin: Area3D = COIN.instantiate()
			var coin_height := 1.1 + float(i % 2) * 0.3
			if i % 2 == 1:
				coin.position = _get_mirror_platform_point(route, i) + Vector3(0, coin_height, 0)
				coin.add_to_group("mirror_dimension")
			else:
				coin.position = point + Vector3(0, coin_height, 0)
				coin.add_to_group("material_dimension")
			world.add_child(coin)

		if i % 3 == 1:
			var cloud := preload("res://objects/cloud.tscn").instantiate()
			cloud.position = point + Vector3(0, 0.9, 0.9)
			world.add_child(cloud)

	var goal: Vector3 = route[route.size() - 1]
	var flag: Node3D = FLAG.instantiate()
	flag.position = goal + Vector3(0, 0.45, 0)
	world.add_child(flag)
	player.position = route[0] + Vector3(0, 0.55, 0)
	player.velocity = Vector3.ZERO
	checkpoint_position = player.position
	active_checkpoint = 0
	for checkpoint_index in _get_checkpoint_indices(level_number, route.size()):
		_add_checkpoint(route[checkpoint_index], checkpoint_index)
	finish.position = goal + Vector3(0, 1.0, 0)
	if level_number in [1, 2, 4, 5]:
		_add_anti_gravity_zone(route[route.size() / 2])
	_build_level_identity(level_number, route)
	_apply_dimension_visibility()


func _get_checkpoint_indices(level_number: int, route_size: int) -> Array[int]:
	var second_checkpoint := route_size - 3
	if level_number == 3:
		# The maze folds close to its start near the end, so place the second marker earlier.
		second_checkpoint = route_size - 5
	return [2, second_checkpoint]


func _add_checkpoint(point: Vector3, checkpoint_index: int) -> void:
	var checkpoint := Node3D.new()
	checkpoint.name = "Checkpoint_%02d" % checkpoint_index
	checkpoint.add_to_group("course_checkpoints")
	checkpoint.set_meta("checkpoint_index", checkpoint_index)
	checkpoint.position = point
	world.add_child(checkpoint)

	var area := Area3D.new()
	area.name = "CheckpointTrigger"
	area.position.y = 0.8
	area.collision_layer = 0
	area.collision_mask = 1
	var trigger_shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 1.05
	trigger_shape.shape = sphere
	area.add_child(trigger_shape)
	checkpoint.add_child(area)

	var pole := MeshInstance3D.new()
	var pole_mesh := CylinderMesh.new()
	pole_mesh.top_radius = 0.045
	pole_mesh.bottom_radius = 0.07
	pole_mesh.height = 1.3
	pole.mesh = pole_mesh
	pole.position.y = 0.72
	pole.material_override = _map_material(Color("#18202b"))
	checkpoint.add_child(pole)

	var flag := MeshInstance3D.new()
	flag.name = "CheckpointFlag"
	var flag_mesh := BoxMesh.new()
	flag_mesh.size = Vector3(0.62, 0.34, 0.055)
	flag.mesh = flag_mesh
	flag.position = Vector3(0.34, 1.16, 0)
	var flag_material := _map_material(Color("#bda334"), true)
	flag.material_override = flag_material
	checkpoint.add_child(flag)
	area.body_entered.connect(_on_checkpoint_body_entered.bind(checkpoint_index, point + Vector3(0, 0.55, 0), flag_material))


func _on_checkpoint_body_entered(body: Node3D, checkpoint_index: int, respawn_point: Vector3, flag_material: StandardMaterial3D) -> void:
	if body != player or checkpoint_index <= active_checkpoint:
		return
	active_checkpoint = checkpoint_index
	checkpoint_position = respawn_point
	flag_material.albedo_color = Color("#ffe25a")
	flag_material.emission = Color("#ffc928")
	hud.show_finish_message("Checkpoint reached! Fall back here if you miss a jump.")


func respawn_player() -> void:
	Engine.time_scale = 1.0
	player.global_position = checkpoint_position
	player.velocity = Vector3.ZERO
	player.movement_velocity = Vector3.ZERO
	player.gravity = 0.0
	player.gravity_scale = 1.0
	player.jump_single = true
	player.jump_double = true
	player.previously_floored = false
	player.model.scale = Vector3.ONE
	hud.show_finish_message("Back at checkpoint %d" % active_checkpoint if active_checkpoint > 0 else "Back at the start")


func _get_mirror_platform_point(route: Array, index: int) -> Vector3:
	var direction: Vector3
	if index == 0:
		direction = route[1] - route[0]
	elif index == route.size() - 1:
		direction = route[index] - route[index - 1]
	else:
		direction = route[index + 1] - route[index - 1]
	direction.y = 0.0
	direction = direction.normalized()
	var side := -1.0 if index % 2 == 0 else 1.0
	var offset := Vector3(-direction.z, 0.0, direction.x) * side * 0.72
	var height_offset := 0.22 if index % 3 == 1 else 0.0
	return route[index] + offset + Vector3(0, height_offset, 0)


func _add_phase_glow(platform: Node3D) -> void:
	var marker := MeshInstance3D.new()
	marker.name = "MirrorPhaseMarker"
	var torus := TorusMesh.new()
	torus.inner_radius = 0.74
	torus.outer_radius = 0.82
	marker.mesh = torus
	marker.position.y = 0.54
	marker.material_override = _map_material(Color("#54f4e8"), true)
	platform.add_child(marker)


func _apply_dimension_visibility() -> void:
	for node in get_tree().get_nodes_in_group("material_dimension"):
		_set_phase_active(node, not mirror_dimension)
	for node in get_tree().get_nodes_in_group("mirror_dimension"):
		_set_phase_active(node, mirror_dimension)


func _set_phase_active(root: Node, active: bool) -> void:
	if root is Node3D:
		(root as Node3D).visible = active
	var collision_nodes := root.find_children("*", "CollisionObject3D", true, false)
	if root is CollisionObject3D:
		collision_nodes.append(root)
	for collision_node in collision_nodes:
		var collision_object := collision_node as CollisionObject3D
		if not collision_object.has_meta("phase_original_layer"):
			collision_object.set_meta("phase_original_layer", collision_object.collision_layer)
			collision_object.set_meta("phase_original_mask", collision_object.collision_mask)
		if active:
			collision_object.collision_layer = int(collision_object.get_meta("phase_original_layer"))
			collision_object.collision_mask = int(collision_object.get_meta("phase_original_mask"))
		else:
			collision_object.collision_layer = 0
			collision_object.collision_mask = 0


func _shift_dimension() -> void:
	mirror_dimension = not mirror_dimension
	_apply_dimension_visibility()
	$Sun.light_color = Color("#a7eaff") if mirror_dimension else Color("#fff2d6")
	hud.show_finish_message("MIRROR DIMENSION" if mirror_dimension else "MATERIAL DIMENSION")


func _build_level_identity(level_number: int, route: Array) -> void:
	match level_number:
		1:
			# Cloud Hop: hoops and sweepers turn the spiral into a timing challenge.
			for index in [2, 5, 8]:
				_add_map_ring(route[index] + Vector3(0, 1.8, 0), 0.92, Color("#83f5ef"))
			for index in [4, 7]:
				_add_spinning_bar(route[index], 1.65, Color("#45d8cf"), 1.35)
		2:
			# Switchback Sprint: low bars make the broad S route a jumping course.
			for index in [2, 5, 8]:
				_add_jump_hurdle(route, index)
			for index in [1, 4, 7]:
				_add_ruin_arch(route[index] + Vector3(0, 0.5, 0), 1.65, 0.8, Color("#ff9b4b"))
		3:
			# Moonflip Maze: alternate solid walls leave a changing gap to find.
			for wall_index in range(3):
				var route_index := 2 + wall_index * 2
				_add_maze_wall(route, route_index, 1.0 if wall_index % 2 == 0 else -1.0)
			for index in [3, 7]:
				_add_map_ring(route[index] + Vector3(0, 1.6, 0), 0.72, Color("#d79bff"))
		4:
			# Rising Ruins: broken columns and sweepers frame the steep ascent.
			for index in [1, 3, 5, 7, 9]:
				var side := -1.0 if index % 2 == 1 else 1.0
				var point: Vector3 = route[index]
				# Ruin stumps frame the route without towering over the player.
				_add_map_column(point + Vector3(side * 1.45, 0, 0), 0.62 + float(index % 3) * 0.1, 0.34, Color("#d6bd91"))
			for index in [4, 8]:
				_add_ruin_arch(route[index] + Vector3(0, 0.5, 0), 1.9, 0.85, Color("#ead8ad"))
			for index in [2, 7]:
				_add_spinning_bar(route[index], 1.8, Color("#b58854"), -1.1)
		5:
			# Sky Crown: golden gates and fast sweepers guard the final ascent.
			for index in [2, 5, 8]:
				_add_ruin_arch(route[index] + Vector3(0, 0.5, 0), 1.9, 0.85, Color("#ffd667"))
				_add_map_ring(route[index] + Vector3(0, 1.25, 0), 0.58, Color("#fff0a1"))
			for index in [4, 7]:
				_add_spinning_bar(route[index], 2.0, Color("#ffca45"), 1.8)
			_add_crown_spires(route[route.size() - 1])


func _add_jump_hurdle(route: Array, route_index: int) -> void:
	var direction: Vector3 = route[route_index + 1] - route[route_index - 1]
	direction.y = 0.0
	var rotation_y := atan2(direction.x, direction.z)
	# Platform tops sit at y + 0.5; this bar is low enough to jump over.
	_add_solid_map_box(route[route_index] + Vector3(0, 0.77, 0), Vector3(1.55, 0.42, 0.24), Color("#ff734f"), rotation_y)


func _add_maze_wall(route: Array, route_index: int, side: float) -> void:
	var direction: Vector3 = route[route_index + 1] - route[route_index]
	direction.y = 0.0
	direction = direction.normalized()
	var across := Vector3(direction.z, 0.0, -direction.x)
	var rotation_y := atan2(direction.x, direction.z)
	var point: Vector3 = route[route_index] + across * side * 0.42 + Vector3(0, 0.95, 0)
	# The wall spans most of each island, so players must follow the alternating openings.
	_add_solid_map_box(point, Vector3(1.05, 0.8, 0.22), Color("#7654b8"), rotation_y)


func _add_solid_map_box(point: Vector3, size: Vector3, tint: Color, rotation_y: float = 0.0) -> void:
	var obstacle := StaticBody3D.new()
	obstacle.name = "CourseObstacle"
	obstacle.add_to_group("material_dimension")
	obstacle.position = point
	obstacle.rotation.y = rotation_y
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	obstacle.add_child(collision)
	var visual := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	visual.mesh = box
	visual.material_override = _map_material(tint)
	obstacle.add_child(visual)
	world.add_child(obstacle)


func _add_spinning_bar(platform_point: Vector3, length: float, tint: Color, speed: float) -> void:
	var obstacle := AnimatableBody3D.new()
	obstacle.name = "SpinningSweeper"
	obstacle.add_to_group("mirror_dimension")
	obstacle.position = platform_point + Vector3(0, 1.05, 0)
	obstacle.set_script(SPINNING_HAZARD_SCRIPT)
	obstacle.set("spin_speed", speed)
	var bar_size := Vector3(length, 0.18, 0.2)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = bar_size
	collision.shape = shape
	obstacle.add_child(collision)
	var visual := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = bar_size
	visual.mesh = box
	visual.material_override = _map_material(tint, true)
	obstacle.add_child(visual)
	world.add_child(obstacle)


func _add_map_ring(point: Vector3, radius: float, tint: Color) -> void:
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = radius - 0.09
	torus.outer_radius = radius
	ring.mesh = torus
	ring.position = point
	ring.rotation.x = PI / 2.0
	ring.material_override = _map_material(tint, true)
	world.add_child(ring)


func _add_map_column(point: Vector3, height: float, radius: float, tint: Color) -> void:
	var column := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius * 0.74
	cylinder.bottom_radius = radius
	cylinder.height = height
	column.mesh = cylinder
	column.position = point + Vector3(0, 0.5 + height * 0.5, 0)
	column.material_override = _map_material(tint)
	world.add_child(column)


func _add_ruin_arch(point: Vector3, width: float, height: float, tint: Color) -> void:
	var pillar_width := 0.22
	_add_map_box(point + Vector3(-width * 0.5, height * 0.5, 0), Vector3(pillar_width, height, pillar_width), tint)
	_add_map_box(point + Vector3(width * 0.5, height * 0.5, 0), Vector3(pillar_width, height, pillar_width), tint)
	_add_map_box(point + Vector3(0, height, 0), Vector3(width + pillar_width, pillar_width, pillar_width), tint)


func _add_crown_spires(point: Vector3) -> void:
	var gold := _map_material(Color("#ffd667"), true)
	for offset in [Vector3(-1.45, 0, -0.9), Vector3(-0.5, 0, -1.55), Vector3(0.5, 0, -1.55), Vector3(1.45, 0, -0.9)]:
		var spire := MeshInstance3D.new()
		var cone := CylinderMesh.new()
		cone.bottom_radius = 0.3
		cone.top_radius = 0.0
		cone.height = 0.85
		spire.mesh = cone
		spire.position = point + offset + Vector3(0, 0.425, 0)
		spire.material_override = gold
		world.add_child(spire)


func _add_map_box(point: Vector3, size: Vector3, tint: Color) -> void:
	var visual := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	visual.mesh = box
	visual.position = point
	visual.material_override = _map_material(tint)
	world.add_child(visual)


func _map_material(tint: Color, emissive: bool = false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.58
	if emissive:
		material.emission_enabled = true
		material.emission = tint
	return material


func _get_level_routes() -> Array:
	return [
		# Cloud Hop: spiral around and climb toward the summit.
		[Vector3(0, 0, 0), Vector3(2.3, 0, 0), Vector3(3.7, 0.6, 1.8), Vector3(2.6, 1.2, 3.6), Vector3(0.3, 1.8, 4.2), Vector3(-2.0, 2.4, 3.0), Vector3(-3.6, 3.0, 1.0), Vector3(-2.5, 3.6, -1.0), Vector3(-0.3, 4.2, -2.1), Vector3(2.0, 4.8, -1.2)],
		# Switchback Sprint: a wide S route that doubles back across the gap.
		[Vector3(0, 0, 0), Vector3(2.4, 0, 1.8), Vector3(4.8, 0.3, 0), Vector3(7.2, 0.6, -1.8), Vector3(9.6, 0.9, 0), Vector3(7.2, 1.2, 1.8), Vector3(4.8, 1.5, 3.6), Vector3(2.4, 1.8, 1.8), Vector3(0, 2.1, 0), Vector3(-2.4, 2.4, -1.8)],
		# Moonflip Maze: a tight sequence of turns folds back across its own track.
		[Vector3(0, 0, 0), Vector3(0, 0, -2.0), Vector3(1.8, 0.4, -3.6), Vector3(3.8, 0.6, -3.6), Vector3(3.8, 0.9, -1.4), Vector3(2.0, 1.1, 0), Vector3(0, 1.4, 0), Vector3(-2.0, 1.7, 0), Vector3(-3.8, 2.0, -1.4), Vector3(-2.0, 2.3, -2.8)],
		# Rising Ruins: climb in a tight switchback over a deep drop.
		[Vector3(0, 0, 0), Vector3(2.2, 0.5, 0), Vector3(4.4, 1, 1), Vector3(6.6, 1.5, 2), Vector3(8.8, 2, 1), Vector3(6.6, 2.5, 0), Vector3(4.4, 3, -1), Vector3(2.2, 3.5, -2), Vector3(0, 4, -1), Vector3(-2.2, 4.5, 0), Vector3(-4.4, 5, 1)],
		# Sky Crown: the longest course, with a sharp zigzag finish.
		[Vector3(0, 0, 0), Vector3(2.2, 0.4, 0), Vector3(4.4, 0.8, -1.8), Vector3(6.6, 0.4, -3.6), Vector3(8.8, 0, -1.8), Vector3(11, 0.5, 0), Vector3(13.2, 1, 1.8), Vector3(15.4, 1.5, 0), Vector3(17.6, 2, -1.8), Vector3(19.8, 2.5, 0), Vector3(22, 3, 1.8)]
	]


func _add_anti_gravity_zone(point: Vector3) -> void:
	var zone := Area3D.new()
	zone.name = "AntiGravityZone"
	zone.position = point + Vector3(0, 1.1, 0)
	zone.collision_layer = 0
	zone.collision_mask = 1
	zone.set_script(GRAVITY_ZONE_SCRIPT)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.2, 3.2, 2.2)
	shape.shape = box
	zone.add_child(shape)
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.72
	torus.outer_radius = 0.9
	ring.mesh = torus
	ring.position.y = -0.75
	var glow := StandardMaterial3D.new()
	glow.albedo_color = Color("#62f5ef")
	glow.emission_enabled = true
	glow.emission = Color("#1acdd1")
	ring.material_override = glow
	zone.add_child(ring)
	world.add_child(zone)


func _build_puzzle_switch() -> void:
	var routes := _get_level_routes()
	var route: Array = routes[current_level - 1]
	var switch_position: Vector3 = route[route.size() - 2] + Vector3(0, 1.0, 0)
	puzzle_switch = Node3D.new()
	puzzle_switch.name = "PuzzleSwitch"
	puzzle_switch.add_to_group("mirror_dimension")
	puzzle_switch.position = switch_position
	var button := CSGCylinder3D.new()
	button.name = "SwitchButton"
	button.radius = 0.48
	button.height = 0.28
	button.position.y = 0.16
	switch_material = StandardMaterial3D.new()
	switch_material.albedo_color = Color("#ff5b72")
	switch_material.emission_enabled = true
	switch_material.emission = Color("#ff254a")
	button.material = switch_material
	puzzle_switch.add_child(button)
	var post := CSGBox3D.new()
	post.size = Vector3(0.16, 0.9, 0.16)
	post.position.y = -0.42
	post.material = StandardMaterial3D.new()
	post.material.albedo_color = Color("#304d72")
	puzzle_switch.add_child(post)
	world.add_child(puzzle_switch)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F1:
		hud.show_controls_hint()
	if event.is_action_pressed("shift_dimension") and not get_tree().paused:
		_shift_dimension()
		return
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
		Engine.time_scale = 1.0
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().change_scene_to_file("res://scenes/home.tscn")
		return
	if event.is_action_pressed("interact") and not puzzle_solved:
		if player.global_position.distance_to(puzzle_switch.global_position) < 2.5:
			puzzle_solved = true
			switch_material.albedo_color = Color("#65f6ad")
			switch_material.emission = Color("#25ff95")
			hud.show_finish_message("Switch activated! The summit gate is open!")


func _on_coin_collected(coins: int) -> void:
	if coins == coin_goal:
		hud.show_finish_message("All coins collected! Find the switch, then reach the flag!")


func _on_finish_body_entered(body: Node3D) -> void:
	if body != player:
		return
	if not puzzle_solved:
		hud.show_finish_message("Find the glowing switch and press E!")
		return
	if player.coins < coin_goal:
		var remaining: int = coin_goal - player.coins
		hud.show_finish_message("Find %d more coin%s!" % [remaining, "s" if remaining != 1 else ""])
		return
	Engine.time_scale = 1.0
	hud.show_victory(current_level, LEVEL_NAMES.size())


func _on_continue_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	var next_level := current_level + 1
	if next_level > LEVEL_NAMES.size():
		next_level = 1
	get_tree().set_meta("level_number", next_level)
	get_tree().reload_current_scene()
