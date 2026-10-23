extends CharacterBody3D

signal coin_collected

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed = 250
@export var jump_strength = 7

var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0
var gravity_scale := 1.0
var time_freeze_active := false
var freeze_cooldown := 0.0

var previously_floored = false

var jumps_remaining := 2

var coins = 0

@onready var particles_trail = $ParticlesTrail
@onready var sound_footsteps = $SoundFootsteps
@onready var model = $Character
@onready var animation = $Character/AnimationPlayer


func _ready() -> void:
	var has_controller_jump := false
	for event in InputMap.action_get_events("jump").duplicate():
		if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_A:
			has_controller_jump = true
		elif event is InputEventJoypadButton and event.button_index == JOY_BUTTON_B:
			InputMap.action_erase_event("jump", event)
	if not has_controller_jump:
		var jump_button := InputEventJoypadButton.new()
		jump_button.button_index = JOY_BUTTON_A
		jump_button.device = -1
		InputMap.action_add_event("jump", jump_button)
	if not _jump_has_mouse_binding():
		var mouse_jump := InputEventMouseButton.new()
		mouse_jump.button_index = MOUSE_BUTTON_LEFT
		mouse_jump.device = -1
		InputMap.action_add_event("jump", mouse_jump)


func _jump_has_mouse_binding() -> bool:
	for event in InputMap.action_get_events("jump"):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			return true
	return false

# Functions

func _physics_process(delta):
	if Input.is_action_just_pressed("time_freeze") and freeze_cooldown <= 0.0:
		_activate_time_freeze()

	# Handle functions

	handle_gravity(delta)
	handle_controls(delta)

	handle_effects(delta)

	# Movement

	var applied_velocity: Vector3

	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity

	velocity = applied_velocity
	move_and_slide()

	# Rotation

	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()

	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)

	# Falling/respawning

	if position.y < -10:
		var level := get_parent()
		if level.has_method("respawn_player"):
			level.respawn_player()
		else:
			get_tree().reload_current_scene()

	# Animation for scale (jumping and landing)

	model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)

	# Animation when landing

	if is_on_floor() and gravity > 2 and !previously_floored:
		model.scale = Vector3(1.25, 0.75, 1.25)
		Audio.play("res://sounds/land.ogg")

	previously_floored = is_on_floor()

# Handle animation(s)

func handle_effects(delta):

	particles_trail.emitting = false
	sound_footsteps.stream_paused = true

	if is_on_floor():
		var horizontal_velocity = Vector2(velocity.x, velocity.z)
		var speed_factor = horizontal_velocity.length() / movement_speed / delta
		if speed_factor > 0.05:
			if animation.current_animation != "walk":
				animation.play("walk", 0.1)

			if speed_factor > 0.3:
				sound_footsteps.stream_paused = false
				sound_footsteps.pitch_scale = speed_factor

			if speed_factor > 0.75:
				particles_trail.emitting = true

		elif animation.current_animation != "idle":
			animation.play("idle", 0.1)

		if animation.current_animation == "walk":
			animation.speed_scale = speed_factor
		else:
			animation.speed_scale = 1.0

	elif animation.current_animation != "jump":
		animation.play("jump", 0.1)

# Handle movement input

func handle_controls(delta):

	# Movement

	var input := Vector3.ZERO

	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")

	input = input.rotated(Vector3.UP, view.rotation.y)

	if input.length() > 1:
		input = input.normalized()

	movement_velocity = input * movement_speed * delta

	# Jumping

	if Input.is_action_just_pressed("jump"):

		if jumps_remaining > 0:
			jump()

# Handle gravity

func handle_gravity(delta):

	if is_on_floor() and gravity >= 0.0:
		gravity = 0
		jumps_remaining = 2
	else:
		gravity += 25 * gravity_scale * delta
		gravity = clampf(gravity, -5.0, 30.0)

# Jumping

func jump():

	Audio.play("res://sounds/jump.ogg")

	gravity = -jump_strength

	model.scale = Vector3(0.5, 1.5, 0.5)

	jumps_remaining = maxi(0, jumps_remaining - 1)


func cloud_bounce() -> void:
	gravity = -9.5
	jumps_remaining = 2
	model.scale = Vector3(0.75, 1.3, 0.75)
	Audio.play("res://sounds/jump.ogg")

# Collecting coins

func collect_coin():

	coins += 1

	coin_collected.emit(coins)


func _activate_time_freeze() -> void:
	if time_freeze_active:
		return
	time_freeze_active = true
	freeze_cooldown = 9.0
	Engine.time_scale = 0.18
	get_tree().create_timer(1.25, true, false, true).timeout.connect(_end_time_freeze)
	get_tree().create_timer(9.0, true, false, true).timeout.connect(func(): freeze_cooldown = 0.0)


func _end_time_freeze() -> void:
	Engine.time_scale = 1.0
	time_freeze_active = false


func set_anti_gravity(enabled: bool) -> void:
	gravity_scale = -0.35 if enabled else 1.0
