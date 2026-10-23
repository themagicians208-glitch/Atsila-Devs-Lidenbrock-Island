extends Control

signal resume_pressed
signal restart_pressed
signal main_menu_pressed

@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var main_menu_button: Button = %MainMenuButton

func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	resume_button.grab_focus()
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_resume_pressed() -> void:
	resume_pressed.emit()

func _on_restart_pressed() -> void:
	restart_pressed.emit()

func _on_main_menu_pressed() -> void:
	main_menu_pressed.emit()

func _notification(what: int) -> void:
	if what == NotificationWMCloseRequest:
		get_tree().quit()