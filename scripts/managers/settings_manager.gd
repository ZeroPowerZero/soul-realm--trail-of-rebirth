extends Node

const SETTINGS_FILE = "user://settings.cfg"

var config: ConfigFile = ConfigFile.new()

func _ready() -> void:
	_load_settings()

func _load_settings() -> void:
	var err = config.load(SETTINGS_FILE)
	if err != OK:
		_save_default_settings()
	else:
		_apply_all_settings()

func _save_default_settings() -> void:
	# Video
	config.set_value("Video", "display_mode", DisplayServer.WINDOW_MODE_WINDOWED)
	config.set_value("Video", "vsync", true) # Using true for enabled
	
	# Audio
	config.set_value("Audio", "master_volume", 1.0)
	config.set_value("Audio", "music_volume", 1.0)
	config.set_value("Audio", "sfx_volume", 1.0)
	
	# Controls
	var custom_actions = ["move_forward", "move_backward", "move_left", "move_right", "jump", "toggle_spell_mode", "escape_mouse", "draw_spell"]
	for action in custom_actions:
		if InputMap.has_action(action):
			var events = InputMap.action_get_events(action)
			if events.size() > 0:
				config.set_value("Controls", action, events[0])

	_save_settings()
	_apply_all_settings()

func _apply_all_settings() -> void:
	# Video
	set_video_mode(config.get_value("Video", "display_mode", DisplayServer.WINDOW_MODE_WINDOWED), false)
	set_vsync(config.get_value("Video", "vsync", true), false)
	
	# Audio
	set_audio_volume("Master", config.get_value("Audio", "master_volume", 1.0), false)
	set_audio_volume("Music", config.get_value("Audio", "music_volume", 1.0), false)
	set_audio_volume("SFX", config.get_value("Audio", "sfx_volume", 1.0), false)
	
	# Controls
	if config.has_section("Controls"):
		for action in config.get_section_keys("Controls"):
			var event = config.get_value("Controls", action)
			if InputMap.has_action(action):
				InputMap.action_erase_events(action)
				InputMap.action_add_event(action, event)

func _save_settings() -> void:
	config.save(SETTINGS_FILE)

# -- Video Settings --
func set_video_mode(mode: int, save: bool = true) -> void:
	DisplayServer.window_set_mode(mode)
	if save:
		config.set_value("Video", "display_mode", mode)
		_save_settings()

func get_video_mode() -> int:
	return config.get_value("Video", "display_mode", DisplayServer.WINDOW_MODE_WINDOWED)

func set_vsync(enabled: bool, save: bool = true) -> void:
	var vsync_mode = DisplayServer.VSYNC_ENABLED if enabled else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(vsync_mode)
	if save:
		config.set_value("Video", "vsync", enabled)
		_save_settings()

func get_vsync() -> bool:
	return config.get_value("Video", "vsync", true)

# -- Audio Settings --
func set_audio_volume(bus_name: String, volume_linear: float, save: bool = true) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		# Convert linear volume (0.0 to 1.0) to decibels (-80 to 0)
		var db = linear_to_db(max(volume_linear, 0.0001)) # prevent -inf
		AudioServer.set_bus_volume_db(bus_idx, db)
		AudioServer.set_bus_mute(bus_idx, volume_linear == 0.0)
	
	if save:
		config.set_value("Audio", bus_name.to_lower() + "_volume", volume_linear)
		_save_settings()

func get_audio_volume(bus_name: String) -> float:
	return config.get_value("Audio", bus_name.to_lower() + "_volume", 1.0)

# -- Control Settings --
func set_keybind(action_name: String, event: InputEvent, save: bool = true) -> void:
	if InputMap.has_action(action_name):
		InputMap.action_erase_events(action_name)
		InputMap.action_add_event(action_name, event)
		if save:
			config.set_value("Controls", action_name, event)
			_save_settings()

func get_keybind(action_name: String) -> InputEvent:
	return config.get_value("Controls", action_name, null)
