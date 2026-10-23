extends CanvasLayer

signal resume_requested
signal restart_requested
signal quit_requested

var resume_btn: Button
var restart_btn: Button
var quit_btn: Button

func _ready() -> void:
	resume_btn = get_node("CenterContainer/VBoxContainer/ResumeButton")
	restart_btn = get_node("CenterContainer/VBoxContainer/RestartButton")
	quit_btn = get_node("CenterContainer/VBoxContainer/QuitButton")
	
	resume_btn.pressed.connect(resume_requested.emit)
	restart_btn.pressed.connect(restart_requested.emit)
	quit_btn.pressed.connect(quit_requested.emit)

func _on_resume_requested() -> void:
	resume_requested.emit()

func _on_restart_requested() -> void:
	restart_requested.emit()

func _on_quit_requested() -> void:
	quit_requested.emit()