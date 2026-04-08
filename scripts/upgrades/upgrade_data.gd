class_name UpgradeData
extends Resource

enum Rarity { COMMON, RARE, EPIC, LEGENDARY }

@export var id: StringName
@export var name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var max_level: int = 1
@export var rarity: Rarity = Rarity.COMMON
@export var weight: float = 10.0 # Higher weight = more common drop

# Virtual function to be overridden
func apply_upgrade(_player: Node) -> void:
	push_error("apply_upgrade() must be overridden in UpgradeData subclass.")
