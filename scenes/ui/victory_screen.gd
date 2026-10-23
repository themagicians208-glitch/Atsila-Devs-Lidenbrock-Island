extends CanvasLayer

signal victory_confirmed

var score_value: Label
var time_value: Label
var collectibles_value: Label
var continue_btn: Button

func _ready() -> void:
	score_value = get_node("CenterContainer/VBoxContainer/ScoreContainer/ScoreValue")
	time_value = get_node("CenterContainer/VBoxContainer/TimeContainer/TimeValue")
	collectibles_value = get_node("CenterContainer/VBoxContainer/CollectiblesContainer/CollectiblesValue")
	continue_btn = get_node("CenterContainer/VBoxContainer/ContinueButton")
	
	continue_btn.pressed.connect(victory_confirmed.emit)

func show_victory(final_score: int, elapsed_time: float, collectibles_found: int = 0, collectibles_total: int = 0) -> void:
	score_value.text = str(final_score)
	var minutes = int(elapsed_time / 60)
	var seconds = int(elapsed_time) % 60
	time_value.text = "%d:%02d" % [minutes, seconds]
	collectibles_value.text = "%d / %d" % [collectibles_found, collectibles_total]