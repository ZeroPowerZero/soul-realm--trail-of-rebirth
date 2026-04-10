extends Control


func _ready() -> void:
	if has_node("MenuPanel/VBoxContainer/PlayButton"):
		$MenuPanel/VBoxContainer/PlayButton.grab_focus()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world/World.tscn")

func _on_settings_button_pressed() -> void:
	var settings_scene := preload("res://scenes/ui/settings_panel.tscn")
	var settings_instance = settings_scene.instantiate()
	add_child(settings_instance)
	
	if has_node("MenuPanel"):
		$MenuPanel.hide()
	
	await settings_instance.closed
	
	if has_node("MenuPanel"):
		$MenuPanel.show()
		if has_node("MenuPanel/VBoxContainer/SettingsButton"):
			$MenuPanel/VBoxContainer/SettingsButton.grab_focus()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
