class_name SpellData
extends Resource

enum SpellType { FIRE, EARTH, WIND, ICE, SHIELD }

@export var name: String
@export var spell_type: SpellType = SpellType.FIRE
@export var spell_scene: PackedScene
