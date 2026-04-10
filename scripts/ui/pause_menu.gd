extends CanvasLayer

@onready var resume_button = $MainPanel/VBoxContainer/ResumeButton

func _ready():
	visible = false

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			toggle_pause()
			get_viewport().set_input_as_handled()

func toggle_pause():
	visible = !visible
	get_tree().paused = visible
	if visible:
		resume_button.grab_focus()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_resume_button_pressed():
	toggle_pause()

func _on_settings_button_pressed():
	var settings_scene := preload("res://scenes/ui/settings_panel.tscn")
	var settings_instance = settings_scene.instantiate()
	settings_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(settings_instance)
	
	if has_node("MainPanel"):
		$MainPanel.hide()
	
	await settings_instance.closed
	
	if has_node("MainPanel"):
		$MainPanel.show()
		var btn = $MainPanel/VBoxContainer.get_node_or_null("SettingsButton")
		if btn:
			btn.grab_focus()

func _on_main_menu_button_pressed():
	# Ensure game is unpaused before transitioning scenes, otherwise Main Menu will be frozen
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
