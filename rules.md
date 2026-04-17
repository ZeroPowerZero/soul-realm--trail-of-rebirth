1. All files and folders must use snake_case naming.

2. All code must be modular — each script should have a single, clear responsibility.

3. Each script must begin with a class_name declaration if it is intended to be reused or
referenced by other nodes.

4. All exported variables must include a type annotation. Example: @export var speed: float = 5.0

5. Private variables and functions must be prefixed with an underscore. Example: var _health: int,
func _calculate_damage() -> void:

6. Signal names must use snake_case and describe an event in past tense.
Example: signal player_died, signal item_collected

7. Constants must use SCREAMING_SNAKE_CASE. Example: const MAX_HEALTH: int = 100

8. All functions must include a return type annotation. Example: func get_speed() -> float:

9. Node references must be cached in _ready() using @onready. Do not use get_node() calls
scattered throughout the code.

10. Scenes must be self-contained — a scene should not directly access or modify the internals
of another scene. Use signals or an autoload manager instead.

11. Autoloads (singletons) must be reserved for truly global systems only (e.g. GameManager,
AudioManager, SaveManager). Do not abuse autoloads as a shortcut for passing data.

12. All resource files (.tres, .res) must be stored under res://resources/ in a logically
name subfolder.

13. Shaders must be stored under res://shaders/ and named after their effect.
Example: chromatic_aberration.gdshader

14. No magic numbers — all numeric literals with non-obvious meaning must be assigned to a
named constant.

15. Dead code, commented-out blocks, and debug print() statements must be removed before
committing.

16. Folder structure must follow a feature-based convention. Keep scenes, scripts, and related
files together in the same feature folder. Only shared resources and global systems are
separated.
res://
├── player/
│   ├── player.tscn
│   └── player.gd
├── enemies/
│   ├── crawler.tscn
│   └── crawler.gd
├── ui/
│   ├── hud.tscn
│   └── hud.gd
├── world/
│   ├── level_01.tscn
│   └── level_manager.gd
├── autoloads/
│   ├── game_manager.gd
│   └── audio_manager.gd
└── resources/
	├── shaders/
	├── materials/
	├── audio/
	├── textures/
	└── fonts/

17. Scripts that are truly shared across multiple features (e.g. utility functions, base
classes) must be placed in a common/ folder at the root level, not scattered inside feature
folders.
