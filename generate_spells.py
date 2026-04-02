import os
import textwrap

base_path = "c:/Users/sharm/OneDrive/Desktop/soul-realm--trail-of-rebirth/scripts/spells/elements/"

spells = [
    {"id": "flames", "name": "Flames", "element": "fire", "type": 0},
    {"id": "stone_throw", "name": "Stone Throw", "element": "earth", "type": 1},
    {"id": "tornado", "name": "Tornado", "element": "wind", "type": 2},
    {"id": "push_back", "name": "Push Back", "element": "wind", "type": 2},
    {"id": "ice_spikes", "name": "Ice Spikes", "element": "ice", "type": 3},
    {"id": "frost_attack", "name": "Frost Attack", "element": "ice", "type": 3},
    {"id": "invisibility_cloak", "name": "Invisibility Cloak", "element": "shield", "type": 4},
    {"id": "front_shield", "name": "Front Shield", "element": "shield", "type": 4},
    {"id": "full_shield", "name": "Full Shield", "element": "shield", "type": 4}
]

for spell in spells:
    dir_path = os.path.join(base_path, spell["element"])
    os.makedirs(dir_path, exist_ok=True)
    
    tres_content = f"""[gd_resource type="Resource" script_class="SpellData" format=3]

[ext_resource type="Script" uid="uid://ds2evghd4d04i" path="res://scripts/spells/Spell_Resources/spell_data.gd" id="1_m6gym"]

[resource]
script = ExtResource("1_m6gym")
name = "{spell['name']}"
spell_type = {spell['type']}
metadata/_custom_type_script = "uid://ds2evghd4d04i"
"""
    tres_path = os.path.join(dir_path, f"{spell['id']}_data.tres")
    if not os.path.exists(tres_path):
        with open(tres_path, 'w') as f:
            f.write(tres_content)
    
print("Spells created!")
