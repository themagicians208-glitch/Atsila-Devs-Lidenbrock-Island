extends Node3D

const PLATFORM := preload("res://objects/platform.tscn")
const PLATFORM_MEDIUM := preload("res://objects/platform_medium.tscn")
const PLATFORM_GRASS := preload("res://objects/platform_grass_large_round.tscn")
const PLATFORM_FALLING := preload("res://objects/platform_falling.tscn")
const COIN := preload("res://objects/coin.tscn")
const FLAG := preload("res://models/flag.glb")
const GRAVITY_ZONE_SCRIPT := preload("res://scripts/anti_gravity_zone.gd")

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


func _ready() -> void:
	Engine.time_scale = 1.0
	_ensure_key_action("interact", KEY_E)
	_ensure_key_action("time_freeze", KEY_F)
	current_level = int(get_tree().get_meta("level_number", 1))
	current_level = clampi(current_level, 1, LEVEL_NAMES.size())
	get_tree().set_meta("level_number", current_level)
	_build_level(current_level)
	coin_goal = get_tree().get_nodes_in_group("collectible_coins").size()
	hud.set_coin_goal(coin_goal)
	hud.set_level_info(current_level, LEVEL_NAMES[current_level - 1])
	hud.continue_pressed.connect(_on_continue_pressed)
	player.coin_collected.connect(_on_coin_collected)
	finish.body_entered.connect(_on_finish_body_entered)
	_build_puzzle_switch()

	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		$Sun.light_energy = 0.24
		$Sun.shadow_opacity = 0.85
		$Environment.environment.background_energy_multiplier = 0.25


func _ensure_key_action(action_name: String, key_code: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
		var key := InputEventKey.new()
		key.physical_keycode = key_code
		InputMap.action_add_event(action_name, key)


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
		elif level_number == 3 and i in [2, 5, 8]:
			platform_scene = PLATFORM_FALLING
		elif level_number == 4 and i in [3, 6]:
			platform_scene = PLATFORM_FALLING
		elif level_number == 5 and i in [2, 5, 8]:
			platform_scene = PLATFORM_FALLING
		var platform: Node3D = platform_scene.instantiate()
		platform.position = point
		platform.rotation.y = float((i * 23 + level_number * 17) % 50) * PI / 180.0
		world.add_child(platform)

		if i > 0 and i < route.size() - 1:
			var coin: Area3D = COIN.instantiate()
			coin.position = point + Vector3(0, 1.1 + float(i % 2) * 0.3, 0)
			world.add_child(coin)

		if i % 3 == 1:
			var cloud := preload("res://objects/cloud.tscn").instantiate()
			cloud.position = point + Vector3(0, 3.5, 1.5)
			world.add_child(cloud)

	var goal: Vector3 = route[route.size() - 1]
	var flag: Node3D = FLAG.instantiate()
	flag.position = goal + Vector3(0, 0.45, 0)
	world.add_child(flag)
	player.position = route[0] + Vector3(0, 0.55, 0)
	player.velocity = Vector3.ZERO
	finish.position = goal + Vector3(0, 1.0, 0)
	if level_number in [1, 2, 4, 5]:
		_add_anti_gravity_zone(route[route.size() / 2])


func _get_level_routes() -> Array:
	return [
		# Cloud Hop: spiral around and climb toward the summit.
		[Vector3(0, 0, 0), Vector3(2.3, 0, 0), Vector3(3.7, 0.6, 1.8), Vector3(2.6, 1.2, 3.6), Vector3(0.3, 1.8, 4.2), Vector3(-2.0, 2.4, 3.0), Vector3(-3.6, 3.0, 1.0), Vector3(-2.5, 3.6, -1.0), Vector3(-0.3, 4.2, -2.1), Vector3(2.0, 4.8, -1.2)],
		# Switchback Sprint: a wide S route that doubles back across the gap.
		[Vector3(0, 0, 0), Vector3(2.4, 0, 1.8), Vector3(4.8, 0.3, 0), Vector3(7.2, 0.6, -1.8), Vector3(9.6, 0.9, 0), Vector3(7.2, 1.2, 1.8), Vector3(4.8, 1.5, 3.6), Vector3(2.4, 1.8, 1.8), Vector3(0, 2.1, 0), Vector3(-2.4, 2.4, -1.8)],
		# Moonflip Maze: a looping path that curls around its center.
		[Vector3(0, 0, 0), Vector3(2.3, 0, -1.6), Vector3(4.6, 0.7, -2.3), Vector3(6.9, 0.7, -1), Vector3(6.9, 1.4, 1.3), Vector3(4.6, 1.4, 2.6), Vector3(2.3, 2.1, 2.2), Vector3(0, 2.1, 0.6), Vector3(-2.3, 2.8, -1.2), Vector3(-4.6, 3.4, -2)],
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
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
		Engine.time_scale = 1.0
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
