extends Control

signal play_pressed
signal quit_pressed

@onready var play_button: Button = %PlayButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	play_button.grab_focus()

func _on_play_pressed() -> void:
	play_pressed.emit()

func _on_quit_pressed() -> void:
	quit_pressed.emit()