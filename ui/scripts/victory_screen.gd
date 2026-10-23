extends Control

signal continue_pressed

@onready var score_label: Label = %ScoreLabel
@onready var time_label: Label = %TimeLabel
@onready var collectibles_label: Label = %CollectiblesLabel
@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	continue_button.grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func setup(final_score: int, completion_time: float, collectibles_found: int, collectibles_total: int) -> void:
	score_label.text = "FINAL SCORE: %d" % final_score
	
	var minutes = int(completion_time / 60)
	var seconds = int(completion_time % 60)
	var milliseconds = int((completion_time - int(completion_time)) * 100)
	time_label.text = "TIME: %02d:%02d.%02d" % [minutes, seconds, milliseconds]
	
	collectibles_label.text = "COLLECTIBLES: %d / %d" % [collectibles_found, collectibles_total]

func _on_continue_pressed() -> void:
	continue_pressed.emit()

func _notification(what: int) -> void:
	if what == NotificationWMCloseRequest:
		get_tree().quit()