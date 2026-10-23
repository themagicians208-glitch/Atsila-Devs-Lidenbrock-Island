extends Node

signal level_completed(level_id: String, score: int, time: float)
signal level_restarted(level_id: String)

var _current_level_id: String = "level_01"
var _level_start_time: float = 0.0

func _ready() -> void:
	_level_start_time = Time.get_ticks_msec() / 1000.0

func load_level(level_id: String) -> void:
	_current_level_id = level_id
	_level_start_time = Time.get_ticks_msec() / 1000.0
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func restart_current() -> void:
	_level_start_time = Time.get_ticks_msec() / 1000.0
	get_tree().reload_current_scene()
	level_restarted.emit(_current_level_id)

func get_current_level_id() -> String:
	return _current_level_id

func get_elapsed_time() -> float:
	return (Time.get_ticks_msec() / 1000.0) - _level_start_time