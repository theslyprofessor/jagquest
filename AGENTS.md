---
created: 2025-12-01T00:00:00-0800
updated: 2025-12-01T00:00:00-0800
edited_seconds: 0
slug: jagquest
template_type: agent
schema_validated: 2025-12-01
type: project-context
parent: ../AGENTS.md
tasks_status: 
tasks_unfinished: 
tasks_completed: 
---
# AGENTS.md - JagQuest

**Purpose:** Godot 4 action RPG for SWC ACDM educational exploration

## Project Overview

JagQuest is a rework of the ACDM School Game, built in Godot 4 using GDScript following HeartBeast's Action RPG tutorial conventions.

## Tech Stack

- **Engine:** Godot 4.2+
- **Language:** GDScript
- **Style:** Pixel art (320x180 base resolution, 4x scale)
- **Tutorial Reference:** [HeartBeast Action RPG](https://www.youtube.com/playlist?list=PL9FzW-m48fn2SlrW0KoLT4n5egNdX-W9a)

## Project Structure

```
jagquest/
├── Player/          # Player CharacterBody2D, states, animations
├── World/           # Level scenes, tilemaps
├── Enemies/         # Enemy AI, bat, etc.
├── UI/              # Health, menus, dialogs
├── Overlap/         # Hitbox/Hurtbox (collision detection)
├── Effects/         # Particles, screen effects
├── Resources/       # Shared .tres files
├── project.godot    # 320x180, pixel art settings
└── icon.svg         # JagQuest icon
```

## HeartBeast Convention Reference

Following the tutorial series structure:

1. **Project Setup** - 320x180 viewport, 2D stretch mode, pixel filter off
2. **Player Movement** - CharacterBody2D with input vector, acceleration/friction
3. **Animation** - AnimationPlayer + AnimationTree with blend spaces
4. **State Machine** - Enum-based states (MOVE, ROLL, ATTACK)
5. **Hitbox/Hurtbox** - Area2D-based collision system
6. **Enemy AI** - Wander, chase, knockback states
7. **UI** - TextureRect hearts, signals for updates

## Key Godot 4 Changes from Tutorial (3.2)

| Godot 3.2 | Godot 4.x |
|-----------|-----------|
| `KinematicBody2D` | `CharacterBody2D` |
| `move_and_slide(velocity)` | `velocity = ...; move_and_slide()` |
| `yield()` | `await` |
| `connect("signal", obj, "method")` | `signal.connect(method)` |
| `export var` | `@export var` |
| `onready var` | `@onready var` |

## Development Workflow

1. **Run game:** F5 in Godot editor
2. **Test scene:** F6 for current scene
3. **Edit scripts:** Built-in editor or external

## Common Tasks

**Add new scene:**
1. Create folder (e.g., `Enemies/Bat/`)
2. Create `.tscn` scene file
3. Attach `.gd` script
4. Instance in World scene

**Add animation:**
1. Select AnimationPlayer
2. Create new animation
3. Add keyframes for Sprite2D frame property
4. Connect to AnimationTree if using blend spaces

## Input Actions

- `ui_left`, `ui_right`, `ui_up`, `ui_down` - Movement (WASD + Arrows)
- `attack` - Space bar
- `roll` - Shift
- `interact` - E key

## SWC Customization Notes

- School colors: Maroon (#8B1A1A) and Gold (#FFD700)
- Jaguar mascot characters
- Campus buildings based on SWC Chula Vista
- Educational content from ACDM programs

## Related Projects

- `acdm-school-game/` - Original Phaser.js web version
- `midimaze/` - Educational content source

## Resources

- [HeartBeast Tutorial Playlist](https://www.youtube.com/playlist?list=PL9FzW-m48fn2SlrW0KoLT4n5egNdX-W9a)
- [Godot 4 Documentation](https://docs.godotengine.org/en/stable/)
- [HeartBeast GitHub](https://github.com/uheartbeast)
