class_name UpgradeUI
extends CanvasLayer

@onready var upgrade_buttons: VBoxContainer = $PanelContainer/CenterContainer/VBoxContainer/UpgradeButtons

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
		var btn = Button.new()
		btn.text = upgrade.name + "\n" + upgrade.description
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
