extends CanvasLayer

@onready var grid_container = $MainPanel/ScrollContainer/GridContainer

var spell_dir_path = "res://scripts/spells/Spell_Resources/"

func _ready():
	visible = false
	_load_spells()

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if String.chr(event.unicode).to_lower() == "m" or event.keycode == KEY_M:
			visible = !visible
			if visible:
				_load_spells()
				get_tree().paused = true
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				get_tree().paused = false
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			# Consume the event to prevent other elements from processing the M key
			get_viewport().set_input_as_handled()

func _load_spells():
	for child in grid_container.get_children():
		child.queue_free()
		
	if Templates.spell_manager == null:
		return
		
	var known_spells = Templates.spell_manager.get_spells()
	for spell_driver in known_spells:
		if spell_driver != null:
			_create_spell_entry(spell_driver)

func _create_spell_entry(spell_driver: SpellDriver):
	var spell = spell_driver.get_data()
	
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(146, 230)
	
	var style = StyleBoxTexture.new()
	var tex = ResourceLoader.load("res://texture/ui/Panel/panel-015.png")
	if tex:
		style.texture = tex
		style.texture_margin_left = 16
		style.texture_margin_top = 16
		style.texture_margin_right = 16
		style.texture_margin_bottom = 16
	else:
		style = StyleBoxFlat.new()
		style.bg_color = Color(0.9, 0.9, 0.9, 1)
		
	panel.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)
	
	var name_label = Label.new()
	name_label.text = spell.name if spell.name != "" else "Unknown"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	name_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(name_label)
	
	var level_label = Label.new()
	level_label.text = "Level " + str(spell_driver.get_level())
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	level_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(level_label)
	
	var desc_label = Label.new()
	desc_label.text = spell.description
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2, 1))
	desc_label.add_theme_font_size_override("font_size", 10)
	desc_label.custom_minimum_size = Vector2(120, 35)
	vbox.add_child(desc_label)
	
	var shape_box = Control.new()
	shape_box.custom_minimum_size = Vector2(60, 60)
	shape_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(shape_box)
	
	var bg_rect = ColorRect.new()
	bg_rect.color = Color(0, 0, 0, 0.3)
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	shape_box.add_child(bg_rect)
	
	var line = Line2D.new()
	line.width = 3.0
	line.default_color = Color(1.0, 0.8, 0.2, 1.0)
	# shape points are rough normalized up to 250 bounding box, center is origin
	var scaled_factor = 25.0 / 125.0
	for pt in spell_driver.get_coords():
		line.add_point((pt * scaled_factor) + Vector2(30, 30))
	shape_box.add_child(line)
	
	var space = Control.new()
	space.custom_minimum_size = Vector2(0, 4)
	vbox.add_child(space)
	
	var type_label = Label.new()
	var type_str = SpellData.SpellType.keys()[spell.spell_type]
	type_label.text = "Type: " + type_str.capitalize()
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	type_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(type_label)
	
	var cost_label = Label.new()
	cost_label.text = "Mana: " + str(spell.mana_cost)
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	cost_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(cost_label)
	
	var cd_label = Label.new()
	cd_label.text = "CD: " + str(spell.reload_time) + "s"
	cd_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cd_label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	cd_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(cd_label)
	
	grid_container.add_child(panel)
