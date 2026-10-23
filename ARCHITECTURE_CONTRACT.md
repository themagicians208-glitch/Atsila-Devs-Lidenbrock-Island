# LIDEN BROCK — ARCHITECTURE CONTRACT & INTEGRATION PLAN
**Project:** Artificial Arcade 2026 — PS01: GlitchVerse — The World Is Broken
**Engine:** Godot 4.7.2
**Scope:** Level 1 only — "THE BROKEN SHORE"
**Role:** Tech Lead & Integration Owner

---

## 1. REPOSITORY STATE (as of inspection)

| Item | Status |
|------|--------|
| Git | Clean `main`, untracked: `.godot/`, `project.godot` |
| Project | Godot 4.7, GLES3 compatibility renderer |
| Scenes | None |
| Scripts | None |
| Assets | None |
| README | Placeholder only |

**No existing work to preserve.** Full greenfield for Level 1.

---

## 2. FILE OWNERSHIP CONTRACT

| Path / Subsystem | Owner Agent | Notes |
|------------------|-------------|-------|
| `project.godot` | **Tech Lead (me)** | Input map, autoloads, main scene, project settings |
| `scenes/main.tscn` | **Tech Lead (me)** | Root scene, level instancing, global systems |
| `scenes/levels/level_01_broken_shore.tscn` | **Level Designer** | Level geometry, spawn points, exit, collectibles placement |
| `scenes/player/player.tscn` | **Player Systems** | CharacterBody3D, camera, movement, gravity shift input |
| `scenes/player/player.gd` | **Player Systems** | Movement API, gravity shift trigger, interaction raycast |
| `scenes/mechanics/gravity_zone.tscn` | **Mechanics** | Area3D zone, gravity direction/strength, visual indicator |
| `scenes/mechanics/gravity_zone.gd` | **Mechanics** | `GravityZone` class, `gravity_vector` property, `on_body_entered` |
| `scenes/interactables/pressure_plate.tscn` | **Puzzle Systems** | StaticBody3D, collision, signal `activated(deactivator)` |
| `scenes/interactables/pressure_plate.gd` | **Puzzle Systems** | `Interactable` interface, weight detection |
| `scenes/interactables/physics_crate.tscn` | **Puzzle Systems** | RigidBody3D, grabbable, `Interactable` |
| `scenes/interactables/physics_crate.gd` | **Puzzle Systems** | Pickup/throw, mass, `Interactable` |
| `scenes/interactables/exit_door.tscn` | **Puzzle Systems** | AnimatedSprite3D/AnimationPlayer, `locked` property |
| `scenes/interactables/exit_door.gd` | **Puzzle Systems** | `unlock()`, `on_body_entered` → level complete |
| `scenes/interactables/collectible.tscn` | **Puzzle Systems** | Area3D, rotation animation, `collected` signal |
| `scenes/interactables/collectible.gd` | **Puzzle Systems** | Score value, particle effect on collect |
| `scripts/interfaces/interactable.gd` | **Tech Lead (me)** | **Shared interface** — `interact()`, `can_interact()`, `get_prompt()` |
| `scripts/interfaces/gravity_shiftable.gd` | **Tech Lead (me)** | **Shared interface** — `apply_gravity_shift(vector)` |
| `scripts/core/score_manager.gd` | **UI/Systems** | Autoload. `add(points)`, `get_score()`, `reset()`, `score_changed` signal |
| `scripts/core/level_manager.gd` | **Tech Lead (me)** | Autoload. `load_level(id)`, `restart_current()`, `level_completed(level_id)` signal |
| `scripts/core/input_actions.gd` | **Tech Lead (me)** | Constants for input action names (single source of truth) |
| `scenes/ui/hud.tscn` | **UI/Systems** | CanvasLayer, score label, objective text, interaction prompt |
| `scenes/ui/hud.gd` | **UI/Systems** | Binds to `ScoreManager`, `LevelManager`, `Player` signals |
| `scenes/ui/pause_menu.tscn` | **UI/Systems** | CanvasLayer, resume/restart/quit buttons |
| `scenes/ui/pause_menu.gd` | **UI/Systems** | `pause_requested`, `resume_requested`, `restart_requested` signals |
| `scenes/ui/victory_screen.tscn` | **UI/Systems** | CanvasLayer, final score, time, continue button |
| `scenes/ui/victory_screen.gd` | **UI/Systems** | `victory_confirmed` signal → LevelManager |
| `scripts/player/player_movement.gd` | **Player Systems** | Extracted movement logic (separation of concerns) |
| `scripts/player/gravity_shift.gd` | **Player Systems** | Gravity shift cooldown, visual feedback, camera reorientation |

**Forbidden:** No agent creates/modifies files outside their column without Tech Lead approval.

---

## 3. SHARED CONTRACTS (Interfaces & Signals)

### 3.1 Input Actions (project.godot `[input]` section)
```
move_forward      = "ui_up", "w"
move_backward     = "ui_down", "s"
move_left         = "ui_left", "a"
move_right        = "ui_right", "d"
jump              = "ui_accept", "space"
gravity_shift     = "shift", "mouse_middle"
interact          = "e", "mouse_right"
pause             = "ui_cancel", "escape"
look_horizontal   = "mouse_move_x" (raw)
look_vertical     = "mouse_move_y" (raw)
```

### 3.2 Interactable Interface (`scripts/interfaces/interactable.gd`)
```gdscript
@interface
class_name Interactable
func can_interact(interactor: Node3D) -> bool: pass
func interact(interactor: Node3D): pass
func get_prompt() -> String: pass  # e.g. "Press E to pickup", "Press E to activate"
```

### 3.3 Gravity Shiftable Interface (`scripts/interfaces/gravity_shiftable.gd`)
```gdscript
@interface
class_name GravityShiftable
func apply_gravity_shift(new_gravity: Vector3): pass
```

### 3.4 Player API (`scenes/player/player.gd`)
```gdscript
class_name Player extends CharacterBody3D
# Signals
signal gravity_shifted(new_gravity: Vector3)
signal interact_target_changed(target: Interactable | null)
signal collectible_picked_up(value: int)

# Public API
func get_camera() -> Camera3D: ...
func get_movement_state() -> Dictionary: ...  # {velocity, is_on_floor, gravity_dir}
func request_gravity_shift(): void  # Called by input, triggers cooldown + shift
```

### 3.5 ScoreManager API (Autoload `ScoreManager`)
```gdscript
signal score_changed(new_score: int)
func add(points: int): void
func get_score() -> int: ...
func reset(): void
```

### 3.6 LevelManager API (Autoload `LevelManager`)
```gdscript
signal level_completed(level_id: String, score: int, time: float)
signal level_restarted(level_id: String)
func load_level(level_id: String): void
func restart_current(): void
func get_current_level_id() -> String: ...
```

### 3.7 HUD Signals (UI ↔ Core)
```gdscript
# HUD listens to:
ScoreManager.score_changed
LevelManager.level_completed
Player.interact_target_changed
Player.collectible_picked_up

# HUD emits (PauseMenu):
pause_requested
resume_requested
restart_requested
quit_requested

# VictoryScreen emits:
victory_confirmed  # → LevelManager.load_level("level_02") later
```

### 3.8 Puzzle Completion Contract
- **PressurePlate** emits `activated(activator: Node3D)` / `deactivated()`
- **ExitDoor** has `unlock()` method; when unlocked + player enters → `LevelManager.level_completed.emit("level_01", score, time)`
- **Collectible** emits `collected(value: int)` → `ScoreManager.add(value)`

---

## 4. SCENE HIERARCHY & PATHS

```
main.tscn (root)
├── WorldEnvironment
├── LevelInstance (Level_01_Broken_Shore instance)
│   ├── LevelGeometry (StaticBody3D + MeshInstance3D)
│   ├── SpawnPoint (Marker3D @ name="player_spawn")
│   ├── ExitPoint (Marker3D @ name="exit_spawn")
│   ├── GravityZones (Node3D)
│   │   ├── Zone_Normal (GravityZone @ gravity=(0,-9.8,0))
│   │   ├── Zone_Inverted (GravityZone @ gravity=(0,9.8,0))
│   │   └── Zone_Sideways (GravityZone @ gravity=(9.8,0,0))
│   ├── PuzzleElements (Node3D)
│   │   ├── PressurePlate_01 (PressurePlate @ name="plate_exit")
│   │   ├── PhysicsCrate_01 (PhysicsCrate @ spawn near plate)
│   │   └── ExitDoor_01 (ExitDoor @ locked=true)
│   └── Collectibles (Node3D)
│       ├── Collectible_01..N (Collectible @ value=100)
├── Player (Player instance @ spawn)
├── HUD (HUD instance)
├── PauseMenu (PauseMenu instance, hidden)
└── VictoryScreen (VictoryScreen instance, hidden)
```

**Node Naming Convention:** `PascalCase_Type_Index` (e.g., `PressurePlate_01`, `GravityZone_Inverted`)

---

## 5. GRAVITY SHIFT MECHANIC SPEC

- **Trigger:** `gravity_shift` input action (Shift / Middle Mouse)
- **Cooldown:** 1.5s (configurable)
- **Behavior:** Cycles through predefined gravity directions in current zone OR global cycle [Down, Up, Left, Right, Forward, Back]
- **Visual:** Camera lerp rotation (0.3s), player "fall" animation, screen shader distortion
- **Affected:** Player (CharacterBody3D), RigidBody3D (crates), CharacterBody3D enemies (future)
- **Zone Override:** Inside `GravityZone`, shift cycles only that zone's allowed directions

---

## 6. LEVEL 1 PUZZLE FLOW (Broken Shore)

1. **Spawn** on beach, see exit door (locked) across gap
2. **Collectibles** (5×) scattered → 500 pts total
3. **Physics crate** near pressure plate
4. **Gravity shift** needed to reach crate / cross gap / activate plate
5. **Pressure plate** holds door open while weighted
6. **Player** steps on plate OR places crate → door unlocks
7. **Enter door** → VictoryScreen → Level Complete

**Win Condition:** Player enters ExitDoor trigger while unlocked
**Loss Condition:** Fall into void (Y < -50) → auto-restart
**Restart:** PauseMenu "Restart" or `R` key → `LevelManager.restart_current()`

---

## 7. INTEGRATION SEQUENCE (Build Order)

| Phase | Owner | Deliverable | Test Criteria |
|-------|-------|-------------|---------------|
| 0 | Tech Lead | `project.godot` input map, autoloads, `main.tscn` skeleton | Project runs, empty level loads |
| 1 | Player Systems | `player.tscn` + movement + camera + gravity shift input | WASD + mouse look + jump + Shift cycles gravity |
| 2 | Mechanics | `gravity_zone.tscn` + visual debug | Player gravity changes in zones |
| 3 | Puzzle Systems | `pressure_plate`, `physics_crate`, `exit_door`, `collectible` | All interact, signals fire |
| 4 | Level Designer | `level_01_broken_shore.tscn` assembled | Playable puzzle flow works |
| 5 | UI/Systems | `hud`, `pause_menu`, `victory_screen` + `ScoreManager`, `LevelManager` | Score updates, pause/restart, victory triggers |
| 6 | Tech Lead | Integration, polish, bug fixes | **Level 1 complete, shippable** |

---

## 8. TESTING CHECKLIST (Level 1 Definition of Done)

- [ ] Player moves smoothly (no jitter, consistent speed)
- [ ] Mouse look clamps vertical (-85° to +85°)
- [ ] Jump only on floor, variable height (hold = higher)
- [ ] Gravity Shift: cooldown respected, camera reorients, physics objects fall correctly
- [ ] Pressure plate: activates with player OR crate, deactivates when empty
- [ ] Exit door: locked → unlock on plate → open on player enter → victory
- [ ] Collectibles: rotate, glow, add score, disappear, particle effect
- [ ] HUD: score updates real-time, objective text updates, interaction prompt shows near interactables
- [ ] Pause: ESC pauses time, shows menu, Resume/Restart/Quit work
- [ ] Restart: Resets score, player position, puzzle state, gravity
- [ ] Victory: Shows final score/time, continues to next level (stub)
- [ ] Fall void: Auto-restart with brief fade
- [ ] No console errors, no memory leaks (10+ min playtest)

---

## 9. NEXT ACTIONS (Tech Lead)

1. Write `project.godot` input map + autoloads
2. Create `scripts/interfaces/*.gd` (contracts first)
3. Create `scripts/core/*.gd` autoloads
4. Scaffold `main.tscn` with placeholder level instance
5. Assign agents to Phases 1–5 above

**No code written by other agents until this contract is acknowledged.**

---

**Signed:** Tech Lead & Integration Owner
**Date:** 2026-10-23