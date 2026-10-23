extends Node

@onready var ui_manager = UIManager

var demo_state = 0
var demo_timer = 0.0

func _ready() -> void:
	ui_manager.main_menu_play_pressed.connect(_on_play)
	ui_manager.main_menu_quit_pressed.connect(_on_quit)
	ui_manager.pause_menu_resume_pressed.connect(_on_resume)
	ui_manager.pause_menu_restart_pressed.connect(_on_restart)
	ui_manager.pause_menu_main_menu_pressed.connect(_on_main_menu)
	ui_manager.victory_screen_continue_pressed.connect(_on_victory_continue)
	
	ui_manager.show_main_menu()

func _process(delta: float) -> void:
	if demo_state == 0:
		return
	elif demo_state == 1:
		demo_timer += delta
		if demo_timer > 1.0:
			ui_manager.update_score(randi() % 10000)
			demo_timer = 0.0
	elif demo_state == 2:
		demo_timer += delta
		if demo_timer > 3.0:
			ui_manager.show_interaction_prompt("Press E to activate terminal")
			demo_timer = 0.0
			demo_state = 3
	elif demo_state == 3:
		demo_timer += delta
		if demo_timer > 2.0:
			ui_manager.hide_interaction_prompt()
			demo_timer = 0.0
			demo_state = 4
	elif demo_state == 4:
		demo_timer += delta
		if demo_timer > 1.0:
			ui_manager.update_gravity_shift("COOLDOWN", fmod(demo_timer, 5.0), 5.0)
		if demo_timer > 6.0:
			ui_manager.update_gravity_shift("READY", 0.0, 5.0)
			demo_timer = 0.0
			demo_state = 5
	elif demo_state == 5:
		demo_timer += delta
		if demo_timer > 2.0:
			ui_manager.show_pause_menu()
			demo_state = 6

func _on_play() -> void:
	ui_manager.hide_main_menu()
	ui_manager.show_hud()
	ui_manager.update_score(0)
	ui_manager.update_collectibles(0, 5)
	ui_manager.update_objective("Find the gravity core to stabilize the sector")
	ui_manager.update_gravity_shift("READY", 0.0, 5.0)
	demo_state = 1

func _on_quit() -> void:
	get_tree().quit()

func _on_resume() -> void:
	ui_manager.hide_pause_menu()
	demo_state = 1

func _on_restart() -> void:
	ui_manager.hide_pause_menu()
	ui_manager.hide_hud()
	ui_manager.show_hud()
	ui_manager.update_score(0)
	ui_manager.update_collectibles(0, 5)
	ui_manager.update_objective("Find the gravity core to stabilize the sector")
	ui_manager.update_gravity_shift("READY", 0.0, 5.0)
	demo_state = 1

func _on_main_menu() -> void:
	ui_manager.hide_pause_menu()
	ui_manager.hide_hud()
	ui_manager.show_main_menu()
	demo_state = 0

func _on_victory_continue() -> void:
	ui_manager.hide_victory_screen()
	ui_manager.show_main_menu()
	demo_state = 0

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if demo_state == 1:
				ui_manager.show_pause_menu()
				demo_state = 6
			elif demo_state == 6:
				ui_manager.hide_pause_menu()
				demo_state = 1
		elif event.keycode == KEY_V and demo_state == 1:
			ui_manager.hide_hud()
			ui_manager.show_victory_screen(8500, 125.5, 5, 5)
			demo_state = 7
		elif event.keycode == KEY_F and demo_state == 1:
			ui_manager.show_failure_message("GRAVITY ANOMALY DETECTED\nReality destabilization imminent", false)
			demo_state = 8
		elif event.keycode == KEY_S and demo_state == 1:
			ui_manager.show_failure_message("PLAYER STUCK IN GEOMETRY\nPress R to respawn at last checkpoint", true)
			demo_state = 8