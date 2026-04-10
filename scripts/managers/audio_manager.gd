extends Node

var bgm_player: AudioStreamPlayer
var sfx_players: Array = []
var current_sfx_index: int = 0
const MAX_SFX_PLAYERS = 8

var ui_click_sound: AudioStream
var spell_cast_sound: AudioStream

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # Keep playing when paused
	
	# Setup BGM
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Music"
	add_child(bgm_player)
	
	var bgm_stream = load("res://assets/kenney_rpg-audio/Preview.ogg")
	if bgm_stream:
		if bgm_stream is AudioStreamOggVorbis:
			bgm_stream.loop = true
		bgm_player.stream = bgm_stream
		bgm_player.play()
		
	# Setup SFX Players
	for i in range(MAX_SFX_PLAYERS):
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		sfx_players.append(p)
		
	# Load specific sounds
	ui_click_sound = load("res://assets/kenney_rpg-audio/Audio/metalClick.ogg")
	spell_cast_sound = load("res://assets/kenney_rpg-audio/Audio/drawKnife1.ogg")
	
	# Global Button Hook
	get_tree().node_added.connect(_on_node_added)
	_hook_existing_buttons(get_tree().root)

func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		_connect_button(node)

func _hook_existing_buttons(node: Node) -> void:
	if node is BaseButton:
		_connect_button(node)
	for child in node.get_children():
		_hook_existing_buttons(child)

func _connect_button(btn: BaseButton) -> void:
	if not btn.pressed.is_connected(_play_ui_click):
		btn.pressed.connect(_play_ui_click)

func _play_ui_click() -> void:
	if ui_click_sound:
		play_sfx(ui_click_sound)

func play_spell_sfx() -> void:
	if spell_cast_sound:
		play_sfx(spell_cast_sound)

func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	var player = sfx_players[current_sfx_index] as AudioStreamPlayer
	player.stream = stream
	player.play()
	current_sfx_index = (current_sfx_index + 1) % MAX_SFX_PLAYERS
