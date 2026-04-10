class_name SpellUpgradeData
extends UpgradeData

@export var target_spell_name: String = "fire_ball"
@export var damage_increase: float = 10.0
@export var level_increase: int = 1

func apply_upgrade(player: Node) -> void:
	# Spells are managed by the global Templates.spell_manager
	if not Templates.spell_manager:
		push_error("Templates.spell_manager not found!")
		return
		
	var applied = false
	for spell in Templates.spell_manager.get_spells():
		if spell.get_data().name == target_spell_name:
			spell.set_damage(spell.get_damage() + damage_increase)
			spell.set_level(spell.get_level() + level_increase)
			applied = true
			break
			
	if applied:
		Templates.save_spells()
		print("Upgraded Spell: ", target_spell_name, " by ", damage_increase, " damage!")
	else:
		push_warning("Tried to upgrade spell ", target_spell_name, " but player hasn't unlocked it yet!")
