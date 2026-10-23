extends Node

func _ready() -> void:
	_setup_input_actions()

func _setup_input_actions() -> void:
	# Keyboard actions
	_add_action("move_forward", KEY_W)
	_add_action("move_forward", KEY_UP)
	_add_action("move_backward", KEY_S)
	_add_action("move_left", KEY_A)
	_add_action("move_right", KEY_D)
	_add_action("jump", KEY_SPACE)
	_add_action("jump", KEY_ENTER)
	_add_action("sprint", KEY_SHIFT)
	_add_action("gravity_shift", KEY_G)
	_add_action("interact", KEY_E)
	_add_action("pause", KEY_ESCAPE)
	_add_action("toggle_camera", KEY_C)
	_add_action("mouse_capture", KEY_ESCAPE)
	_add_action("restart", KEY_R)
	
	# Mouse actions
	_add_mouse_action("gravity_shift", MOUSE_BUTTON_MIDDLE)
	_add_mouse_action("interact", MOUSE_BUTTON_RIGHT)
	_add_mouse_action("zoom_in", MOUSE_BUTTON_WHEEL_UP)
	_add_mouse_action("zoom_out", MOUSE_BUTTON_WHEEL_DOWN)
	
	# Set deadzones
	InputMap.action_set_deadzone("move_forward", 0.5)
	InputMap.action_set_deadzone("move_backward", 0.5)
	InputMap.action_set_deadzone("move_left", 0.5)
	InputMap.action_set_deadzone("move_right", 0.5)
	InputMap.action_set_deadzone("jump", 0.5)
	InputMap.action_set_deadzone("sprint", 0.5)
	InputMap.action_set_deadzone("gravity_shift", 0.5)
	InputMap.action_set_deadzone("interact", 0.5)
	InputMap.action_set_deadzone("pause", 0.5)
	InputMap.action_set_deadzone("toggle_camera", 0.5)
	InputMap.action_set_deadzone("mouse_capture", 0.5)
	InputMap.action_set_deadzone("restart", 0.5)

func _add_action(action_name: String, keycode: int) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var event = InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	InputMap.action_add_event(action_name, event)
	InputMap.action_set_deadzone(action_name, 0.5)

func _add_mouse_action(action_name: String, button_index: int) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var event = InputEventMouseButton.new()
	event.button_index = button_index
	InputMap.action_add_event(action_name, event)
	InputMap.action_set_deadzone(action_name, 0.5)