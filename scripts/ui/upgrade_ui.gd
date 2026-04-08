class_name UpgradeUI
extends CanvasLayer

var panel: PanelContainer
var vbox: VBoxContainer
var upgrade_buttons: VBoxContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	
	panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(panel)
	
	var center = CenterContainer.new()
	panel.add_child(center)
	
	vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	center.add_child(vbox)
	
	var title = Label.new()
	title.text = "LEVEL UP! Choose an Upgrade:"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	upgrade_buttons = VBoxContainer.new()
	upgrade_buttons.add_theme_constant_override("separation", 15)
	vbox.add_child(upgrade_buttons)
	
	hide()
	
	if Engine.get_main_loop().root.has_node("GameManager"):
		var gm = Engine.get_main_loop().root.get_node("GameManager")
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
	
	for upgrade in available_upgrades:
		var btn = Button.new()
		btn.text = upgrade.name + "\n" + upgrade.description
		btn.pressed.connect(_on_upgrade_selected.bind(upgrade, player))
		upgrade_buttons.add_child(btn)

func _on_upgrade_selected(upgrade: UpgradeData, player: Node) -> void:
	var upgrade_comp = player.get_node_or_null("UpgradeComponent")
	if upgrade_comp:
		upgrade_comp.add_upgrade(upgrade)
		upgrade.apply_upgrade(player)
		
	hide()
	get_tree().paused = false
