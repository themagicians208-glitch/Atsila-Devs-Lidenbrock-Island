# Player Controller Subsystem - Integration Guide

## Overview
This document describes the Player Controller subsystem for Liden Brock Level 1 (PS01 GlitchVerse).
The subsystem owns: `scenes/player/Player.tscn`, `scenes/player/player_controller.gd`, `scenes/player/camera_controller.gd`

## Required Input Actions (Project Settings → Input Map)
The integration owner MUST add these actions to `project.godot` under `[input]`:

```
[input]
move_forward = { "deadzone": 0.5, "events": [ { "type": "Key", "keycode": 87 } ] }  # W
move_backward = { "deadzone": 0.5, "events": [ { "type": "Key", "keycode": 83 } ] }  # S
move_left = { "deadzone": 0.5, "events": [ { "type": "Key", "keycode": 65 } ] }  # A
move_right = { "deadzone": 0.5, "events": [ { "type": "Key", "keycode": 68 } ] }  # D
sprint = { "deadzone": 0.5, "events": [ { "type": "Key", "keycode": 16777248 } ] }  # Left Shift
jump = { "deadzone": 0.5, "events": [ { "type": "Key", "keycode": 32 } ] }  # Space
toggle_camera = { "deadzone": 0.5, "events": [ { "type": "Key", "keycode": 67 } ] }  # C
mouse_capture = { "deadzone": 0.5, "events": [ { "type": "Key", "keycode": 16777217 } ] }  # Escape
zoom_in = { "deadzone": 0.5, "events": [ { "type": "MouseButton", "button_index": 4 } ] }  # Wheel Up
zoom_out = { "deadzone": 0.5, "events": [ { "type": "MouseButton", "button_index": 5 } ] }  # Wheel Down
```

## PlayerController API (for Gravity Shift Subsystem)

### Signals
- `gravity_changed(gravity_direction: Vector3)` - Emitted when gravity direction changes
- `fell_out_of_world(reset_pos: Vector3)` - Emitted when player falls below `fall_death_height`

### Methods
```gdscript
# Call this to change gravity direction (e.g., from Gravity Shift subsystem)
set_gravity_direction(direction: Vector3) -> void
# direction: Normalized Vector3 pointing in the direction gravity pulls (e.g., Vector3.DOWN, Vector3.UP)

get_gravity_direction() -> Vector3
get_gravity_strength() -> float
set_gravity_strength(strength: float) -> void

get_velocity() -> Vector3
is_grounded() -> bool
```

### Gravity Direction Convention
- `Vector3.DOWN` (0, -1, 0) = Normal gravity (default)
- `Vector3.UP` (0, 1, 0) = Inverted gravity
- `Vector3.LEFT` (-1, 0, 0) = Gravity pulls left
- Any normalized Vector3 is valid

### Integration Example (Gravity Shift Subsystem)
```gdscript
var player: PlayerController

func _ready():
	player = get_node("Player")  # or wherever Player is instanced
	player.gravity_changed.connect(_on_gravity_changed)

func shift_gravity(new_direction: Vector3):
	player.set_gravity_direction(new_direction)

func _on_gravity_changed(dir: Vector3):
	print("Gravity changed to: ", dir)
	# Update visual effects, audio, etc.
```

## CameraController API

### Signals
- `camera_mode_changed(is_first_person: bool)` - Emitted when toggling camera mode
- `gravity_orientation_changed(gravity_dir: Vector3)` - Emitted when gravity changes (for visual effects)

### Methods
```gdscript
get_movement_basis() -> Basis  # Used by PlayerController for movement direction
is_first_person() -> bool
set_first_person(enabled: bool) -> void
get_camera() -> Camera3D
on_gravity_changed(new_gravity_dir: Vector3) -> void  # Called automatically by PlayerController
```

## Scene Structure
```
Player (CharacterBody3D) [PlayerController script]
├── CollisionShape3D (BoxShape3D 0.8x1.8x0.8)
├── CameraController (Node3D) [CameraController script]
│   ├── Camera3D (current=true)
│   ├── FPPivot (Node3D) - First person camera position
│   └── TPPivot (Node3D) - Third person camera pivot
│       └── ThirdPersonCameraCollision (CollisionShape3D, disabled)
└── MeshInstance3D (CapsuleMesh, visible=false) - For debugging
```

## Configurable Parameters (Inspector)

### PlayerController
| Parameter | Default | Description |
|-----------|---------|-------------|
| walk_speed | 5.0 | Walking speed (m/s) |
| sprint_speed | 10.0 | Sprinting speed (m/s) |
| acceleration | 20.0 | Ground acceleration |
| air_acceleration | 10.0 | Air acceleration |
| friction | 15.0 | Ground friction |
| jump_velocity | 7.5 | Jump impulse |
| coyote_time | 0.1 | Grace period after leaving ground |
| jump_buffer_time | 0.1 | Input buffer before landing |
| base_gravity | 9.81 | Gravity strength |
| max_fall_speed | 30.0 | Terminal velocity |
| fall_death_height | -50.0 | Y threshold for reset |
| reset_position | (0,0,0) | Respawn position |

### CameraController
| Parameter | Default | Description |
|-----------|---------|-------------|
| fp_vertical_fov | 90.0 | First person FOV |
| tp_distance | 4.0 | Third person distance |
| tp_min_distance | 1.5 | Min zoom distance |
| tp_max_distance | 10.0 | Max zoom distance |
| mouse_sensitivity | 0.002 | Mouse look sensitivity |
| invert_y | false | Invert vertical look |
| pitch_limit_min | -85.0 | Min pitch (degrees) |
| pitch_limit_max | 85.0 | Max pitch (degrees) |
| rotation_smoothing | 15.0 | Rotation lerp speed |
| position_smoothing | 20.0 | Position lerp speed |

## Known Issues / Limitations
1. **MeshInstance3D visible=false** - No default player model. Integration owner should replace with actual character mesh.
2. **Third person collision shape disabled** - Enable `ThirdPersonCameraCollision` in inspector if camera collision is desired.
3. **Gravity transitions** - Rapid gravity flips may cause brief camera disorientation. Consider adding interpolation in Gravity Shift subsystem.
4. **No ledge grab / mantle** - Only basic jump implemented.
5. **No crouch / prone** - Not implemented per scope.

## Testing Checklist
- [ ] Walk in all directions (WASD)
- [ ] Sprint (Hold Shift)
- [ ] Jump (Space) - test coyote time and jump buffer
- [ ] Mouse look - verify smooth rotation
- [ ] Toggle camera (C) - verify first/third person switch
- [ ] Mouse capture/release (Escape)
- [ ] Zoom in third person (Mouse wheel)
- [ ] Fall off world - verify reset at `fall_death_height`
- [ ] Call `set_gravity_direction(Vector3.UP)` - verify inverted movement
- [ ] Call `set_gravity_direction(Vector3.LEFT)` - verify sideways gravity
- [ ] Verify camera reorients correctly with gravity changes

## File Ownership
- **OWNED BY PLAYER SUBSYSTEM** (do not modify externally):
  - `scenes/player/player_controller.gd`
  - `scenes/player/camera_controller.gd`
  - `scenes/player/Player.tscn`
- **OWNED BY INTEGRATION OWNER** (must configure):
  - `project.godot` → `[input]` section
  - Main scene that instances `Player.tscn`
  - Gravity Shift subsystem that calls `set_gravity_direction()`

## Version
Godot 4.7.2 compatible
Typed GDScript