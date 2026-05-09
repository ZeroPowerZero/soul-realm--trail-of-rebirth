class_name SpellData
extends Resource

enum SpellType { FIRE, EARTH, WIND, ICE, SHIELD }

@export var name: String
@export var spell_type: SpellType = SpellType.FIRE
@export var spell_scene: PackedScene
@export var mana_cost: float = 10.0
@export var base_damage: float = 10.0
@export var reload_time: float = 1.0
@export var description: String = "A mysterious spell."
