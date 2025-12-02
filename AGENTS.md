---
created: 2025-12-01T00:00:00-0800
updated: 2025-12-01T00:00:00-0800
slug: jagquest
template_type: agent
schema_validated: 2025-12-01
type: project-context
parent: ../AGENTS.md
---
# AGENTS.md - JagQuest

**Purpose:** Godot 4 educational action RPG for SWC ACDM exploration

## Project Overview

JagQuest is a complete rework of the ACDM School Game, featuring:
- **Campus View:** Navigate the actual SWC Chula Vista campus map
- **Room View:** Zelda SNES-style interiors for each program
- **JagGenie:** Fuzzy finder teleport system (Tab/G to activate)
- **Dual Navigation:** Keyboard (WASD) or mouse-click movement

## Tech Stack

- **Engine:** Godot 4.2+
- **Language:** GDScript
- **Style:** Campus map overlay with pixel art rooms
- **Reference:** HeartBeast Action RPG conventions

## Project Structure

```
jagquest/
├── Data/
│   └── game_data.gd          # All ACDM data (programs, buildings, staff)
├── Player/
│   ├── player.gd             # Jaguar character with dual nav
│   └── player.tscn
├── Overworld/
│   ├── overworld.gd          # Campus View mode
│   └── overworld.tscn        # Campus map with building areas
├── Rooms/
│   ├── program_room.gd       # Room template
│   └── [12 program rooms]    # Individual program interiors
├── JagGenie/
│   ├── jag_genie.gd          # Fuzzy finder teleport
│   └── jag_genie.tscn
├── Icons/                    # Entity type icons
├── Transitions/              # Screen transition effects
├── main.gd                   # Game state controller
├── main.tscn                 # Main scene
└── project.godot
```

## Game States

1. **CAMPUS_VIEW** - Overworld navigation on campus map
2. **ROOM_VIEW** - Inside a program room (Zelda-style)
3. **TRANSITIONING** - Playing fade animation

## Data Structure

All game data is in `Data/game_data.gd`:
- **BUILDINGS:** Campus buildings with map positions (normalized 0-1)
- **PROGRAMS:** 12 ACDM programs with degrees, descriptions, building assignments
- **STAFF:** Dean, counselor, success coach, receptionist
- **DEPARTMENTS:** 5 ACDM departments

### Building → Program Mapping
| Building | Programs |
|----------|----------|
| 87 (ACDM) | Architecture, Art, CAD |
| 84 | Recording Arts |
| 57A | Journalism, Communication |
| 35 (Mayan Hall) | Theatre, Dance |
| 83 | Music |
| 85 | Film |
| 24 | Liberal Arts, Mexican American Studies |

## Controls

| Action | Key(s) |
|--------|--------|
| Move | WASD / Arrow keys |
| Move to point | Left click |
| JagGenie | Tab or G |
| Interact | E |
| Exit/Cancel | Escape |

## Running the Game

```bash
# Open in Godot 4
godot --path ~/Code/github.com/theslyprofessor/jagquest

# Or open Godot → Import → Select project.godot
# Press F5 to run
```

## Next Steps (TODOs)

1. **Add campus map image** - Download SWC map PDF, convert to PNG, add to Overworld
2. **Create icon assets** - Building, Program, Person, Office icons
3. **Jaguar sprite** - Animated character (idle, walk 4 directions)
4. **12 program rooms** - Individual scenes with themed layouts
5. **Office portal system** - Teleport between office and program rooms

## Related Projects

- `acdm-school-game/` - Original Phaser.js version (data source)
- `midimaze/` - Content source for educational materials

## Campus Map Reference

PDF: https://www.swccd.edu/about-swc/campus-maps-and-directions/chula-vista-campus/_files/chula-vista-campus-map.pdf

Building positions are normalized (0-1) in game_data.gd and scaled to actual map dimensions in Overworld.
