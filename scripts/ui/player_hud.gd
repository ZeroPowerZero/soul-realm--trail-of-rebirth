class_name PlayerHUD
extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar
@onready var mana_bar: ProgressBar = $MarginContainer/VBoxContainer/ManaBar
@onready var xp_bar: ProgressBar = $MarginContainer/VBoxContainer/XPBar

var player_health_comp: Node
var player_mana_comp: Node

func setup(health_comp: Node, mana_comp: Node) -> void:
	player_health_comp = health_comp
	player_mana_comp = mana_comp

func _ready() -> void:
	if Engine.get_main_loop().root.has_node("GameManager"):
		var gm = Engine.get_main_loop().root.get_node("GameManager")
		if not gm.xp_updated.is_connected(_on_xp_updated):
			gm.xp_updated.connect(_on_xp_updated)
		_on_xp_updated(gm.current_xp, gm.xp_required)

func _process(_delta: float) -> void:
	if is_instance_valid(player_health_comp) and health_bar:
		health_bar.max_value = player_health_comp.max_health
		health_bar.value = player_health_comp.get_health() if player_health_comp.has_method("get_health") else 0
		
	if is_instance_valid(player_mana_comp) and mana_bar:
		if "max_mana" in player_mana_comp and "current_mana" in player_mana_comp:
			mana_bar.max_value = player_mana_comp.max_mana
			mana_bar.value = player_mana_comp.current_mana

func _on_xp_updated(current: float, required: float) -> void:
	if xp_bar:
		xp_bar.max_value = required
		xp_bar.value = current
