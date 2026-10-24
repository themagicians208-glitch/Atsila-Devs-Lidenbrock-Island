extends Control

const UI_FONT = preload("res://fonts/lilita_one_regular.ttf")
const LEVEL_NAMES := ["Cloud Hop", "Switchback Sprint", "Moonflip Maze", "Rising Ruins", "Sky Crown", "Gimmick Gauntlet"]

var popup: ColorRect
var popup_title: Label
var popup_body: VBoxContainer
var back_button: Button
var default_button: Button

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Audio.play_music("res://sounds/pixelland.mp3")
	_build_home()
	_build_popup()
	default_button.grab_focus()

func _build_home() -> void:
	var background := TextureRect.new()
	background.texture = preload("res://sprites/skybox.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var shade := ColorRect.new()
	shade.color = Color(0.035, 0.075, 0.17, 0.38)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 86)
	margin.add_theme_constant_override("margin_right", 86)
	margin.add_theme_constant_override("margin_top", 54)
	margin.add_theme_constant_override("margin_bottom", 48)
	add_child(margin)

	var columns := HBoxContainer.new()
	columns.alignment = BoxContainer.ALIGNMENT_CENTER
	columns.add_theme_constant_override("separation", 68)
	margin.add_child(columns)

	var content := VBoxContainer.new()
	content.custom_minimum_size.x = 520
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 14)
	columns.add_child(content)

	var tag := _label("A SIX-LEVEL DIMENSION-HOPPING ADVENTURE", 18, Color("#a6f4ff"))
	content.add_child(tag)

	var title := _label("SKYBOUND\nSHOWDOWN", 68, Color("#fff1a3"))
	title.add_theme_color_override("font_shadow_color", Color(0.05, 0.08, 0.2, 0.8))
	title.add_theme_constant_override("shadow_offset_x", 3)
	title.add_theme_constant_override("shadow_offset_y", 5)
	content.add_child(title)

	var subtitle := _label("Shift dimensions. Reveal the route.\nCan you reach the crown?", 23, Color.WHITE)
	subtitle.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.45))
	content.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 8
	content.add_child(spacer)

	var play := _button("START ADVENTURE", Color("#ffd451"), Color("#493600"))
	default_button = play
	play.pressed.connect(func(): _start_level(1))
	content.add_child(play)

	var levels := _button("CHOOSE A LEVEL", Color("#315784"), Color.WHITE)
	levels.pressed.connect(_show_level_select)
	content.add_child(levels)

	var controls := _button("HOW TO PLAY", Color("#315784"), Color.WHITE)
	controls.pressed.connect(_show_controls)
	content.add_child(controls)

	var settings := _button("SETTINGS", Color("#315784"), Color.WHITE)
	settings.pressed.connect(_show_settings)
	content.add_child(settings)

	var quit := _button("QUIT GAME", Color("#263e64"), Color("#d6e6ff"))
	quit.pressed.connect(func(): get_tree().quit())
	content.add_child(quit)

	var feature_card := PanelContainer.new()
	feature_card.custom_minimum_size = Vector2(350, 340)
	feature_card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	feature_card.add_theme_stylebox_override("panel", _panel_style(Color(0.04, 0.11, 0.24, 0.82), Color("#6fe7ef")))
	columns.add_child(feature_card)
	var feature_list := VBoxContainer.new()
	feature_list.alignment = BoxContainer.ALIGNMENT_CENTER
	feature_list.add_theme_constant_override("separation", 17)
	feature_card.add_child(feature_list)
	feature_list.add_child(_label("THE SKY IS YOURS", 28, Color("#ffe078")))
	feature_list.add_child(_label("6 unique obstacle courses", 20, Color.WHITE))
	feature_list.add_child(_label("Shift between two dimensions", 20, Color.WHITE))
	feature_list.add_child(_label("Freeze time to beat hazards", 20, Color.WHITE))
	feature_list.add_child(_label("Float through anti-gravity", 20, Color.WHITE))
	feature_list.add_child(_label("Find switches to open the way", 20, Color.WHITE))
	feature_list.add_child(_label("Ice, see-saws, barrels, fans & more", 17, Color("#c7f0b9")))

	var footer := _label("WASD / LEFT STICK MOVE     MOUSE / RIGHT STICK LOOK     CLICK / SPACE / A JUMP", 15, Color("#eff8ff"))
	footer.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	footer.offset_left = -500
	footer.offset_top = -34
	footer.offset_right = 500
	footer.offset_bottom = -8
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(footer)

func _build_popup() -> void:
	popup = ColorRect.new()
	popup.color = Color(0.025, 0.045, 0.09, 0.78)
	popup.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	popup.visible = false
	add_child(popup)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	popup.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(540, 0)
	panel.add_theme_stylebox_override("panel", _panel_style(Color("#17324f"), Color("#ffd66b")))
	center.add_child(panel)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	layout.add_theme_constant_override("margin_left", 32)
	layout.add_theme_constant_override("margin_right", 32)
	layout.add_theme_constant_override("margin_top", 28)
	layout.add_theme_constant_override("margin_bottom", 28)
	panel.add_child(layout)
	popup_title = _label("", 34, Color("#ffe078"))
	popup_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(popup_title)
	popup_body = VBoxContainer.new()
	popup_body.add_theme_constant_override("separation", 10)
	layout.add_child(popup_body)
	var back := _button("BACK", Color("#315784"), Color.WHITE)
	back_button = back
	back.pressed.connect(_close_popup)
	layout.add_child(back)

func _show_level_select() -> void:
	popup_title.text = "CHOOSE YOUR COURSE"
	_clear_popup_body()
	for i in range(LEVEL_NAMES.size()):
		var level_number := i + 1
		var level_button := _button("LEVEL %d   •   %s" % [level_number, LEVEL_NAMES[i].to_upper()], Color("#27496f"), Color.WHITE)
		level_button.pressed.connect(_start_level.bind(level_number))
		popup_body.add_child(level_button)
	popup.visible = true
	if popup_body.get_child_count() > 0:
		(popup_body.get_child(0) as Control).grab_focus()

func _show_controls() -> void:
	popup_title.text = "HOW TO PLAY"
	_clear_popup_body()
	for line in ["WASD / LEFT STICK   Move", "MOUSE / RIGHT STICK   Look around", "LEFT CLICK / SPACE / A   Jump", "RIGHT CLICK / Q / LEFT BUMPER   Shift dimensions", "F / Y   Slow time", "E / X   Activate the nearby switch", "MOUSE WHEEL / TRIGGERS   Zoom", "CLICK / A   Select     ESC / B   Back"]:
		var row := _label(line, 19, Color.WHITE)
		row.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		popup_body.add_child(row)
	popup.visible = true
	back_button.grab_focus()


func _show_settings() -> void:
	var settings := get_node_or_null("/root/Settings")
	if settings == null:
		return
	popup_title.text = "SETTINGS"
	_clear_popup_body()
	popup_body.add_child(_slider_row(
		"MOUSE SENSITIVITY", 0.05, 0.6, 0.01, float(settings.mouse_sensitivity),
		func(value: float) -> String: return "%.2f" % value,
		func(value: float) -> void: settings.set_mouse_sensitivity(value)))
	popup_body.add_child(_slider_row(
		"MASTER VOLUME", 0.0, 1.0, 0.01, float(settings.master_volume),
		func(value: float) -> String: return "%d%%" % roundi(value * 100.0),
		func(value: float) -> void: settings.set_master_volume(value)))
	popup_body.add_child(_graphics_row(settings))
	popup.visible = true
	back_button.grab_focus()


func _slider_row(caption: String, min_value: float, max_value: float, step: float, value: float, formatter: Callable, on_change: Callable) -> VBoxContainer:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	var label := _label("%s   %s" % [caption, formatter.call(value)], 18, Color.WHITE)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.value = value
	slider.custom_minimum_size = Vector2(440, 26)
	slider.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	slider.value_changed.connect(func(new_value: float) -> void:
		label.text = "%s   %s" % [caption, formatter.call(new_value)]
		on_change.call(new_value))
	row.add_child(slider)
	return row


func _graphics_row(settings: Node) -> VBoxContainer:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	var label := _label("GRAPHICS QUALITY", 18, Color.WHITE)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(label)
	var options := OptionButton.new()
	options.custom_minimum_size = Vector2(440, 38)
	options.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	options.add_theme_font_override("font", UI_FONT)
	options.add_theme_font_size_override("font_size", 18)
	options.add_item("LOW", 0)
	options.add_item("MEDIUM", 1)
	options.add_item("HIGH", 2)
	options.select(int(settings.graphics_quality))
	options.item_selected.connect(func(index: int) -> void: settings.set_graphics_quality(index))
	row.add_child(options)
	return row


func _unhandled_input(event: InputEvent) -> void:
	if popup.visible and event.is_action_pressed("ui_cancel"):
		_close_popup()


func _close_popup() -> void:
	popup.visible = false
	default_button.grab_focus()

func _clear_popup_body() -> void:
	for child in popup_body.get_children():
		popup_body.remove_child(child)
		child.queue_free()

func _start_level(level_number: int) -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().set_meta("level_number", level_number)
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", UI_FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _button(text: String, color: Color, text_color: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(390, 48)
	button.add_theme_font_override("font", UI_FONT)
	button.add_theme_font_size_override("font_size", 21)
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _panel_style(color, color.lightened(0.14)))
	button.add_theme_stylebox_override("hover", _panel_style(color.lightened(0.13), Color("#ffe078")))
	button.add_theme_stylebox_override("pressed", _panel_style(color.darkened(0.15), Color("#ffe078")))
	button.add_theme_stylebox_override("focus", _panel_style(color, Color("#a6f4ff")))
	return button

func _panel_style(color: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(16)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	return style
