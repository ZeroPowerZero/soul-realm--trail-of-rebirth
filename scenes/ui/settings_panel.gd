extends Control

signal closed

@onready var fullscreen_btn: CheckButton = %FullscreenBtn
@onready var vsync_btn: CheckButton = %VsyncBtn

@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider

@onready var back_button: Button = %BackButton
@onready var controls_container: VBoxContainer = %ControlsContainer

var is_remapping: bool = false
var action_to_remap: String = ""
var remapping_button: Button = null

func _ready() -> void:
	# Load Current Values
	_load_video_values()
	_load_audio_values()
	_load_controls_values()
	
	fullscreen_btn.toggled.connect(_on_fullscreen_toggled)
	vsync_btn.toggled.connect(_on_vsync_toggled)
	
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	
	back_button.pressed.connect(_on_back_button_pressed)

func _load_video_values() -> void:
	fullscreen_btn.button_pressed = SettingsManager.get_video_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	vsync_btn.button_pressed = SettingsManager.get_vsync()

func _load_audio_values() -> void:
	master_slider.value = SettingsManager.get_audio_volume("Master")
	music_slider.value = SettingsManager.get_audio_volume("Music")
	sfx_slider.value = SettingsManager.get_audio_volume("SFX")

func _load_controls_values() -> void:
	for child in controls_container.get_children():
		if child is HBoxContainer:
			var btn = child.get_node("BindButton")
			var action_name = child.name
			var event = SettingsManager.get_keybind(action_name)
			
			if event:
				if event is InputEventKey:
					btn.text = OS.get_keycode_string(event.physical_keycode)
				elif event is InputEventMouseButton:
					btn.text = "Mouse " + str(event.button_index)
			else:
				btn.text = "Unbound"
			
			if not btn.pressed.is_connected(_on_remap_button_pressed):
				btn.pressed.connect(_on_remap_button_pressed.bind(btn, action_name))

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	var mode = DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED
	SettingsManager.set_video_mode(mode)

func _on_vsync_toggled(toggled_on: bool) -> void:
	SettingsManager.set_vsync(toggled_on)

func _on_master_changed(value: float) -> void:
	SettingsManager.set_audio_volume("Master", value)

func _on_music_changed(value: float) -> void:
	SettingsManager.set_audio_volume("Music", value)

func _on_sfx_changed(value: float) -> void:
	SettingsManager.set_audio_volume("SFX", value)

func _on_back_button_pressed() -> void:
	closed.emit()
	queue_free()

func _on_remap_button_pressed(btn: Button, action: String) -> void:
	if is_remapping:
		return
	is_remapping = true
	action_to_remap = action
	remapping_button = btn
	btn.text = "Press any key..."

func _input(event: InputEvent) -> void:
	if is_remapping:
		if event is InputEventKey or (event is InputEventMouseButton and event.pressed):
			SettingsManager.set_keybind(action_to_remap, event)
			if event is InputEventKey:
				remapping_button.text = OS.get_keycode_string(event.physical_keycode)
			elif event is InputEventMouseButton:
				remapping_button.text = "Mouse " + str(event.button_index)
			
			is_remapping = false
			action_to_remap = ""
			remapping_button = null
			get_viewport().set_input_as_handled()
