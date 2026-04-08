class_name PlayerHUD
extends CanvasLayer

var health_bar: ProgressBar
var mana_bar: ProgressBar
var xp_bar: ProgressBar

var player_health_comp: Node
var player_mana_comp: Node

func setup(health_comp: Node, mana_comp: Node) -> void:
	player_health_comp = health_comp
	player_mana_comp = mana_comp

func _ready() -> void:
	layer = 10
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.set_anchors_preset(Control.PRESET_TOP_LEFT)
	add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(300, 0)
	margin.add_child(vbox)
	
	var hp_label = Label.new()
	hp_label.text = "Health"
	vbox.add_child(hp_label)
	
	health_bar = ProgressBar.new()
	health_bar.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(health_bar)
	
	var mana_label = Label.new()
	mana_label.text = "Mana"
	vbox.add_child(mana_label)
	
	mana_bar = ProgressBar.new()
	mana_bar.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(mana_bar)
	
	var xp_label = Label.new()
	xp_label.text = "XP"
	vbox.add_child(xp_label)
	
	xp_bar = ProgressBar.new()
	xp_bar.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(xp_bar)
	
	if Engine.get_main_loop().root.has_node("GameManager"):
		var gm = Engine.get_main_loop().root.get_node("GameManager")
		if not gm.xp_updated.is_connected(_on_xp_updated):
			gm.xp_updated.connect(_on_xp_updated)
		_on_xp_updated(gm.current_xp, gm.xp_required)

func _process(_delta: float) -> void:
	if is_instance_valid(player_health_comp):
		health_bar.max_value = player_health_comp.max_health
		health_bar.value = player_health_comp.get_health() if player_health_comp.has_method("get_health") else 0
		
	if is_instance_valid(player_mana_comp):
		if "max_mana" in player_mana_comp and "current_mana" in player_mana_comp:
			mana_bar.max_value = player_mana_comp.max_mana
			mana_bar.value = player_mana_comp.current_mana

func _on_xp_updated(current: float, required: float) -> void:
	xp_bar.max_value = required
	xp_bar.value = current
