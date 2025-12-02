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
| Move to point | Option+Click |
| Zoom | Scroll wheel, -/= |
| Resize Jaguar | [ / ] |
| JagGenie | Tab or G |
| Interact | E |
| Exit/Cancel | Escape |

## Viewport & Camera System

The game uses a **unified bounds system** where all limits derive from master constants in `Player/player.gd`.

### Master Constants (Single Source of Truth)

All bounds are defined in `Player/player.gd` lines 14-32:

```gdscript
const SVG_SCALE: float = 4.0
const PLAYABLE_WIDTH: float = 816.0 * SVG_SCALE   # 3264
const PLAYABLE_HEIGHT: float = 880.0 * SVG_SCALE  # 3520 - adjust to hide legend

const PLAYER_PADDING: float = 10.0
const MAP_MIN_X: float = PLAYER_PADDING           # Derived
const MAP_MAX_X: float = PLAYABLE_WIDTH - PLAYER_PADDING
const MAP_MIN_Y: float = PLAYER_PADDING
const MAP_MAX_Y: float = PLAYABLE_HEIGHT - PLAYER_PADDING
```

### How It Works

1. **SVG imported at 4x scale** (see `Assets/campus_map_clean.svg.import`)
2. **PLAYABLE_WIDTH/HEIGHT** define the visible/walkable rectangle
3. **Camera limits** set at runtime from these constants in `_ready()`
4. **Min zoom** calculated automatically: `min(viewport_w/PLAYABLE_WIDTH, viewport_h/PLAYABLE_HEIGHT)`
5. **Player bounds** derived with padding from playable area

### To Adjust the Playable Area

**Only edit ONE place:** `Player/player.gd` line 23

```gdscript
const PLAYABLE_HEIGHT: float = 880.0 * SVG_SCALE  # Change 880.0 to show more/less
```

- **Increase** (e.g., 920.0) → shows more of the legend
- **Decrease** (e.g., 850.0) → crops more of the legend

The scene file (`player.tscn`) has initial values but they're **overwritten at runtime** by `_ready()`.

### Bounds Hierarchy

```
┌─────────────────────────────────────────────────────────┐
│  VIEWPORT (project.godot: 1200 x 900)                   │
│  - Window pixel size                                    │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │  CAMERA LIMITS (set from PLAYABLE_WIDTH/HEIGHT)   │  │
│  │  - 0 to 3264 (width), 0 to 3520 (height)          │  │
│  │  - Min zoom calculated to fit this in viewport    │  │
│  │                                                   │  │
│  │  ┌─────────────────────────────────────────────┐  │  │
│  │  │  WALKABLE AREA (with PLAYER_PADDING)        │  │  │
│  │  │  - 10 to 3254 (X), 10 to 3510 (Y)           │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Current Values

| Constant | Value | Purpose |
|----------|-------|---------|
| `SVG_SCALE` | 4.0 | Import scale from .import file |
| `PLAYABLE_WIDTH` | 3264 | 816 × 4 |
| `PLAYABLE_HEIGHT` | 3520 | 880 × 4 (adjust 880 to tune) |
| `PLAYER_PADDING` | 10 | Edge buffer for jaguar |
| `MAX_CAMERA_ZOOM` | 4.0 | Maximum zoom in |
| `min_camera_zoom` | ~0.27 | Calculated at runtime |

### Features

- **Click-drag panning:** Regular click+drag moves camera
- **Option+Click:** Walk jaguar to location  
- **Scroll wheel:** Zoom in/out (reversed: up=out, down=in)
- **Zoom-relative speed:** Jaguar moves same % of viewport at any zoom
- **Off-screen indicator:** Shows jaguar position when panned away

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
