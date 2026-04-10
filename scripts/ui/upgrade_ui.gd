class_name UpgradeUI
extends CanvasLayer

@onready var upgrade_buttons: HBoxContainer = $MainPanel/HBoxContainer

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if Engine.get_main_loop().root.has_node("GameManager"):
		var gm = Engine.get_main_loop().root.get_node("GameManager")
		if not gm.leveled_up.is_connected(show_upgrade_screen):
			gm.leveled_up.connect(show_upgrade_screen)

func show_upgrade_screen(_level: int) -> void:
	# Get Player
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() == 0:
		return
		
	var player = players[0]
	var upgrade_comp = player.get_node_or_null("UpgradeComponent")
	if not upgrade_comp:
		return
		
	var upgrade_manager = get_node_or_null("/root/UpgradeManager")
	if not upgrade_manager:
		return
		
	# Clear old buttons
	for child in upgrade_buttons.get_children():
		child.queue_free()
		
	var available_upgrades = upgrade_manager.get_random_upgrades(upgrade_comp, 3)
	if available_upgrades.size() == 0:
		return # No upgrades available
		
	get_tree().paused = true
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	for upgrade in available_upgrades:
		_create_upgrade_card(upgrade, player)

func _create_upgrade_card(upgrade: UpgradeData, player: Node) -> void:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(210, 300)
	
	var style_n = StyleBoxTexture.new()
	var tex_n = ResourceLoader.load("res://texture/ui/Panel/panel-015.png")
	style_n.texture = tex_n
	style_n.texture_margin_left = 20
	style_n.texture_margin_top = 20
	style_n.texture_margin_right = 20
	style_n.texture_margin_bottom = 20
	
	var style_h = StyleBoxTexture.new()
	var tex_h = ResourceLoader.load("res://texture/ui/Panel/panel-017.png")
	style_h.texture = tex_h
	style_h.texture_margin_left = 20
	style_h.texture_margin_top = 20
	style_h.texture_margin_right = 20
	style_h.texture_margin_bottom = 20
	
	var style_p = StyleBoxTexture.new()
	var tex_p = ResourceLoader.load("res://texture/ui/Panel/panel-016.png")
	style_p.texture = tex_p
	style_p.texture_margin_left = 20
	style_p.texture_margin_top = 20
	style_p.texture_margin_right = 20
	style_p.texture_margin_bottom = 20
	
	var base_color = Color(1.0, 1.0, 1.0, 1)
	match upgrade.rarity:
		UpgradeData.Rarity.COMMON: base_color = Color(0.9, 0.9, 0.9, 1)
		UpgradeData.Rarity.RARE: base_color = Color(0.6, 0.8, 1.0, 1)
		UpgradeData.Rarity.EPIC: base_color = Color(0.8, 0.6, 1.0, 1)
		UpgradeData.Rarity.LEGENDARY: base_color = Color(1.0, 0.9, 0.5, 1)
		
	style_n.modulate_color = base_color
	style_h.modulate_color = base_color.lightened(0.15)
	style_p.modulate_color = base_color.darkened(0.15)
	
	btn.add_theme_stylebox_override("normal", style_n)
	btn.add_theme_stylebox_override("hover", style_h)
	btn.add_theme_stylebox_override("pressed", style_p)
	btn.add_theme_stylebox_override("focus", style_h)
	
	# Setting mouse filter properly so the elements inside the button don't swallow clicks
	var margin = MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	btn.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)
	
	var name_label = Label.new()
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.text = upgrade.name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.custom_minimum_size = Vector2(170, 0)
	vbox.add_child(name_label)
	
	var space1 = Control.new()
	space1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	space1.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(space1)
	
	var desc_label = Label.new()
	desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc_label.text = upgrade.description
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2, 1))
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.custom_minimum_size = Vector2(170, 100)
	vbox.add_child(desc_label)
	
	var space2 = Control.new()
	space2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	space2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(space2)
	
	var type_label = Label.new()
	type_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	type_label.text = "Rarity: " + UpgradeData.Rarity.keys()[upgrade.rarity].capitalize()
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	match upgrade.rarity:
		UpgradeData.Rarity.COMMON: type_label.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3, 1))
		UpgradeData.Rarity.RARE: type_label.add_theme_color_override("font_color", Color(0.1, 0.4, 0.8, 1))
		UpgradeData.Rarity.EPIC: type_label.add_theme_color_override("font_color", Color(0.6, 0.1, 0.8, 1))
		UpgradeData.Rarity.LEGENDARY: type_label.add_theme_color_override("font_color", Color(0.9, 0.6, 0.0, 1))
		
	type_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(type_label)
	
	btn.pressed.connect(_on_upgrade_selected.bind(upgrade, player))
	upgrade_buttons.add_child(btn)

func _on_upgrade_selected(upgrade: UpgradeData, player: Node) -> void:
	var upgrade_comp = player.get_node_or_null("UpgradeComponent")
	if upgrade_comp:
		upgrade_comp.apply_upgrade(upgrade)
		
	hide()
	get_tree().paused = false
	if not player.get("is_drawing_spell"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
