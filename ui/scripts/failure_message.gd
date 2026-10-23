extends Control

@onready var message_label: Label = %MessageLabel
@onready var hint_label: Label = %HintLabel
@onready var message_panel: PanelContainer = %MessagePanel

var auto_dismiss_timer: Timer = null

func _ready() -> void:
	message_panel.modulate = Color(1, 1, 1, 0)
	message_panel.scale = Vector2(0.8, 0.8)
	var tween = create_tween()
	tween.tween_property(message_panel, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(message_panel, "scale", Vector2(1, 1), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func setup(message: String, is_stuck: bool = false) -> void:
	message_label.text = message
	
	if is_stuck:
		hint_label.text = "Press [color=#ffccaa]R[/color] to respawn at last checkpoint"
		hint_label.bbcode_enabled = true
		hint_label.visible = true
	else:
		hint_label.text = "Respawning..."
		hint_label.visible = true
	
	auto_dismiss_timer = Timer.new()
	auto_dismiss_timer.one_shot = true
	auto_dismiss_timer.wait_time = 3.0 if not is_stuck else 10.0
	auto_dismiss_timer.timeout.connect(_auto_dismiss)
	add_child(auto_dismiss_timer)
	auto_dismiss_timer.start()

func _auto_dismiss() -> void:
	dismiss()

func dismiss() -> void:
	if auto_dismiss_timer:
		auto_dismiss_timer.stop()
		auto_dismiss_timer.queue_free()
		auto_dismiss_timer = null
	
	var tween = create_tween()
	tween.tween_property(message_panel, "modulate:a", 0.0, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(message_panel, "scale", Vector2(0.8, 0.8), 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.finished.connect(queue_free)