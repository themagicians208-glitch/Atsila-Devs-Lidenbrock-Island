extends Node

signal main_menu_play_pressed
signal main_menu_quit_pressed
signal pause_menu_resume_pressed
signal pause_menu_restart_pressed
signal pause_menu_main_menu_pressed
signal victory_screen_continue_pressed

@onready var main_menu_scene = preload("res://ui/scenes/main_menu.tscn")
@onready var hud_scene = preload("res://ui/scenes/hud.tscn")
@onready var pause_menu_scene = preload("res://ui/scenes/pause_menu.tscn")
@onready var victory_screen_scene = preload("res://ui/scenes/victory_screen.tscn")
@onready var failure_message_scene = preload("res://ui/scenes/failure_message.tscn")

var current_hud: Control = null
var current_pause_menu: Control = null
var current_victory_screen: Control = null
var current_failure_message: Control = null

func _ready() -> void:
	pass

func show_main_menu() -> void:
	var main_menu = main_menu_scene.instantiate()
	get_tree().root.add_child(main_menu)
	main_menu.play_pressed.connect(main_menu_play_pressed.emit)
	main_menu.quit_pressed.connect(main_menu_quit_pressed.emit)

func hide_main_menu() -> void:
	for child in get_tree().root.get_children():
		if child is Control and child.has_meta("ui_type") and child.get_meta("ui_type") == "main_menu":
			child.queue_free()
			break

func show_hud() -> void:
	if current_hud:
		current_hud.queue_free()
	current_hud = hud_scene.instantiate()
	get_tree().root.add_child(current_hud)

func hide_hud() -> void:
	if current_hud:
		current_hud.queue_free()
		current_hud = null

func show_pause_menu() -> void:
	if current_pause_menu:
		return
	current_pause_menu = pause_menu_scene.instantiate()
	get_tree().root.add_child(current_pause_menu)
	current_pause_menu.resume_pressed.connect(pause_menu_resume_pressed.emit)
	current_pause_menu.restart_pressed.connect(pause_menu_restart_pressed.emit)
	current_pause_menu.main_menu_pressed.connect(pause_menu_main_menu_pressed.emit)

func hide_pause_menu() -> void:
	if current_pause_menu:
		current_pause_menu.queue_free()
		current_pause_menu = null

func show_victory_screen(final_score: int, completion_time: float, collectibles_found: int, collectibles_total: int) -> void:
	if current_victory_screen:
		current_victory_screen.queue_free()
	current_victory_screen = victory_screen_scene.instantiate()
	get_tree().root.add_child(current_victory_screen)
	current_victory_screen.setup(final_score, completion_time, collectibles_found, collectibles_total)
	current_victory_screen.continue_pressed.connect(victory_screen_continue_pressed.emit)

func hide_victory_screen() -> void:
	if current_victory_screen:
		current_victory_screen.queue_free()
		current_victory_screen = null

func show_failure_message(message: String, is_stuck: bool = false) -> void:
	if current_failure_message:
		current_failure_message.queue_free()
	current_failure_message = failure_message_scene.instantiate()
	get_tree().root.add_child(current_failure_message)
	current_failure_message.setup(message, is_stuck)

func hide_failure_message() -> void:
	if current_failure_message:
		current_failure_message.queue_free()
		current_failure_message = null

func update_score(score: int) -> void:
	if current_hud and current_hud.has_method("update_score"):
		current_hud.update_score(score)

func update_collectibles(found: int, total: int) -> void:
	if current_hud and current_hud.has_method("update_collectibles"):
		current_hud.update_collectibles(found, total)

func update_objective(text: String) -> void:
	if current_hud and current_hud.has_method("update_objective"):
		current_hud.update_objective(text)

func update_gravity_shift(status: String, cooldown: float = 0.0, max_cooldown: float = 1.0) -> void:
	if current_hud and current_hud.has_method("update_gravity_shift"):
		current_hud.update_gravity_shift(status, cooldown, max_cooldown)

func show_interaction_prompt(text: String) -> void:
	if current_hud and current_hud.has_method("show_interaction_prompt"):
		current_hud.show_interaction_prompt(text)

func hide_interaction_prompt() -> void:
	if current_hud and current_hud.has_method("hide_interaction_prompt"):
		current_hud.hide_interaction_prompt()

func set_control_hints(visible: bool) -> void:
	if current_hud and current_hud.has_method("set_control_hints_visible"):
		current_hud.set_control_hints_visible(visible)