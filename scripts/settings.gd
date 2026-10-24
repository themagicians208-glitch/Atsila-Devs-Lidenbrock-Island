extends Node

## Persistent player settings: mouse sensitivity, master volume and graphics
## quality. Saved to user://settings.cfg and applied on startup.

const CONFIG_PATH := "user://settings.cfg"
const DEFAULT_SENSITIVITY := 0.22
const DEFAULT_VOLUME := 1.0
const DEFAULT_GRAPHICS := 2

var mouse_sensitivity := DEFAULT_SENSITIVITY
var master_volume := DEFAULT_VOLUME
var graphics_quality := DEFAULT_GRAPHICS


func _ready() -> void:
	load_settings()
	apply_all()


func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return
	mouse_sensitivity = clampf(float(config.get_value("controls", "mouse_sensitivity", DEFAULT_SENSITIVITY)), 0.02, 1.0)
	master_volume = clampf(float(config.get_value("audio", "master_volume", DEFAULT_VOLUME)), 0.0, 1.0)
	graphics_quality = clampi(int(config.get_value("video", "graphics_quality", DEFAULT_GRAPHICS)), 0, 2)


func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("controls", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("video", "graphics_quality", graphics_quality)
	config.save(CONFIG_PATH)


func set_mouse_sensitivity(value: float) -> void:
	mouse_sensitivity = clampf(value, 0.02, 1.0)
	save_settings()


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	apply_audio()
	save_settings()


func set_graphics_quality(value: int) -> void:
	graphics_quality = clampi(value, 0, 2)
	apply_graphics()
	save_settings()


func apply_all() -> void:
	apply_audio()
	apply_graphics()


func apply_audio() -> void:
	var bus := AudioServer.get_bus_index("Master")
	if bus < 0:
		bus = 0
	if master_volume <= 0.001:
		AudioServer.set_bus_mute(bus, true)
	else:
		AudioServer.set_bus_mute(bus, false)
		AudioServer.set_bus_volume_db(bus, linear_to_db(master_volume))


func apply_graphics() -> void:
	var tree := get_tree()
	if tree == null:
		return
	var root_viewport: Window = tree.root
	match graphics_quality:
		0:
			root_viewport.scaling_3d_scale = 0.55
			root_viewport.msaa_3d = Viewport.MSAA_DISABLED
			root_viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		1:
			root_viewport.scaling_3d_scale = 0.77
			root_viewport.msaa_3d = Viewport.MSAA_DISABLED
			root_viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		_:
			root_viewport.scaling_3d_scale = 1.0
			root_viewport.msaa_3d = Viewport.MSAA_2X
			root_viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA