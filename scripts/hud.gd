extends Control

const UI_FONT = preload("res://fonts/lilita_one_regular.ttf")

@onready var coins_label: Label = $Coins

var coin_goal := 0
var finish_message: Label
var victory_overlay: ColorRect
var level_heading: Label
var victory_heading: Label
var victory_subtitle: Label
var replay_button: Button
var controls_hint: Label
var objective_hint: Label
var controls_tween: Tween
signal continue_pressed

func _ready() -> void:
	_build_game_hud()
	_build_victory_overlay()
	_update_coin_counter(0)

func set_coin_goal(amount: int) -> void:
	coin_goal = amount
	_update_coin_counter(0)

func _on_coin_collected(coins):
	_update_coin_counter(coins)

func show_finish_message(message: String) -> void:
	finish_message.text = message
	finish_message.visible = true
	var timer := get_tree().create_timer(2.5)
	timer.timeout.connect(func(): finish_message.visible = false)

func show_victory(level_number: int, total_levels: int) -> void:
	victory_heading.text = "ALL 5 LEVELS COMPLETE!" if level_number == total_levels else "LEVEL %d COMPLETE!" % level_number
	victory_subtitle.text = "You conquered %s!" % level_heading.text.get_slice("•", 1).strip_edges().capitalize()
	replay_button.text = "PLAY AGAIN" if level_number == total_levels else "NEXT LEVEL"
	victory_overlay.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	replay_button.grab_focus()
	get_tree().paused = true

func set_level_info(level_number: int, level_name: String) -> void:
	level_heading.text = "LEVEL %d  •  %s" % [level_number, level_name.to_upper()]

func show_controls_hint() -> void:
	if not is_instance_valid(controls_hint) or not is_instance_valid(objective_hint):
		return
	if controls_tween and controls_tween.is_running():
		controls_tween.kill()
	controls_hint.visible = true
	controls_hint.modulate.a = 1.0
	objective_hint.visible = true
	objective_hint.modulate.a = 1.0
	controls_tween = create_tween()
	controls_tween.tween_interval(5.0)
	controls_tween.tween_property(controls_hint, "modulate:a", 0.0, 1.0)
	controls_tween.parallel().tween_property(objective_hint, "modulate:a", 0.0, 1.0)
	controls_tween.tween_callback(func():
		controls_hint.visible = false
		objective_hint.visible = false
	)

func _update_coin_counter(coins: int) -> void:	
	if is_instance_valid(coins_label):
		coins_label.text = "%d / %02d" % [coins, coin_goal]

func _build_game_hud() -> void:
	objective_hint = Label.new()
	objective_hint.text = "SHIFT DIMENSIONS  •  COLLECT COINS  •  TOUCH CHECKPOINTS  •  HIT THE SWITCH  •  REACH THE FLAG"
	objective_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	objective_hint.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	objective_hint.offset_left = -600
	objective_hint.offset_top = 24
	objective_hint.offset_right = 600
	objective_hint.offset_bottom = 66
	objective_hint.add_theme_font_override("font", UI_FONT)
	objective_hint.add_theme_font_size_override("font_size", 20)
	objective_hint.add_theme_color_override("font_color", Color("#fff6d5"))
	objective_hint.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.65))
	objective_hint.add_theme_constant_override("shadow_offset_x", 2)
	objective_hint.add_theme_constant_override("shadow_offset_y", 3)
	add_child(objective_hint)

	level_heading = Label.new()
	level_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_heading.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	level_heading.offset_left = -350
	level_heading.offset_top = 122
	level_heading.offset_right = 350
	level_heading.offset_bottom = 154
	level_heading.add_theme_font_override("font", UI_FONT)
	level_heading.add_theme_font_size_override("font_size", 19)
	level_heading.add_theme_color_override("font_color", Color("#8ce7ff"))
	add_child(level_heading)

	controls_hint = Label.new()
	controls_hint.text = "WASD / STICK MOVE   MOUSE / RIGHT STICK LOOK   CLICK / SPACE / A JUMP\nRIGHT CLICK / Q / LB SHIFT   F / Y FREEZE   E / X INTERACT   ESC / B MENU\nF1: SHOW HELP"
	controls_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls_hint.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	controls_hint.offset_left = -540
	controls_hint.offset_top = -90
	controls_hint.offset_right = 540
	controls_hint.offset_bottom = -12
	controls_hint.add_theme_font_override("font", UI_FONT)
	controls_hint.add_theme_font_size_override("font_size", 15)
	controls_hint.add_theme_color_override("font_color", Color("#fff6d5"))
	controls_hint.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	controls_hint.modulate.a = 0.0
	controls_hint.visible = false
	add_child(controls_hint)

	finish_message = Label.new()
	finish_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	finish_message.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	finish_message.offset_left = -350
	finish_message.offset_top = 78
	finish_message.offset_right = 350
	finish_message.offset_bottom = 118
	finish_message.add_theme_font_override("font", UI_FONT)
	finish_message.add_theme_font_size_override("font_size", 24)
	finish_message.add_theme_color_override("font_color", Color("#ffe078"))
	finish_message.visible = false
	add_child(finish_message)

func _build_victory_overlay() -> void:
	victory_overlay = ColorRect.new()
	victory_overlay.color = Color(0.025, 0.045, 0.09, 0.82)
	victory_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	victory_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	victory_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	victory_overlay.visible = false
	add_child(victory_overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	victory_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(500, 250)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#17324f")
	panel_style.border_color = Color("#ffd66b")
	panel_style.set_border_width_all(3)
	panel_style.set_corner_radius_all(18)
	panel_style.content_margin_left = 36
	panel_style.content_margin_right = 36
	panel_style.content_margin_top = 28
	panel_style.content_margin_bottom = 28
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var layout := VBoxContainer.new()
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 14)
	panel.add_child(layout)

	var heading := Label.new()
	victory_heading = heading
	heading.text = "LEVEL COMPLETE!"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_override("font", UI_FONT)
	heading.add_theme_font_size_override("font_size", 42)
	heading.add_theme_color_override("font_color", Color("#ffe078"))
	layout.add_child(heading)

	var subtitle := Label.new()
	victory_subtitle = subtitle
	subtitle.text = "Every coin collected. You made it to the summit!"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_override("font", UI_FONT)
	subtitle.add_theme_font_size_override("font_size", 19)
	subtitle.add_theme_color_override("font_color", Color("#ffffff"))
	layout.add_child(subtitle)

	var replay := Button.new()
	replay.text = "NEXT LEVEL"
	replay.custom_minimum_size = Vector2(210, 48)
	replay.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	replay.add_theme_font_override("font", UI_FONT)
	replay.add_theme_font_size_override("font_size", 22)
	replay.pressed.connect(func(): continue_pressed.emit())
	replay_button = replay
	layout.add_child(replay)
