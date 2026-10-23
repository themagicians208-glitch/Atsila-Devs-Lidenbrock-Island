# Gravity Shift Mechanic - Integration API

## Overview
A reusable gravity reversal component for Godot 4.7.2 that integrates with the existing `PlayerController` API. Handles input, cooldown, stability checks, visual feedback, and emits signals for puzzle systems.

## Files
- `scripts/gravity_shift_component.gd` - Core gravity reversal logic (calls `PlayerController.set_gravity_direction()`)
- `scripts/gravity_affected.gd` - Interface for puzzle objects (reacts to gravity changes)
- `scripts/gravity_volume.gd` - Area-based gravity zones (localized puzzle gravity)
- `scenes/player/player_controller.gd` - Player controller (owns gravity state, exposes `set_gravity_direction()`)
- `scenes/player/camera_controller.gd` - Camera controller (handles gravity-aware orientation)

## Core Component: GravityShiftComponent

### Setup
Attach as child of the **Player** node (which has `PlayerController` script). The component finds the `PlayerController` via `player_controller_path` (default: `".."`).

### Configuration (Export Variables)

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `player_controller_path` | NodePath | `".."` | Path to PlayerController node |
| `gravity_magnitude` | float | 9.81 | Base gravity strength |
| `reversed_gravity_multiplier` | float | 1.0 | Multiplier when reversed |
| `cooldown_time` | float | 0.5 | Minimum time between shifts |
| `shift_duration` | float | 0.3 | Visual transition duration |
| `require_grounded` | bool | false | Only shift when on floor |
| `check_ceiling_clearance` | bool | true | Prevent trapping in geometry |
| `ceiling_clearance` | float | 1.0 | Required space above/below |
| `enable_color_tint` | bool | true | Color feedback on player mesh |
| `normal_color` | Color | (0.2, 0.6, 1.0) | Color when gravity normal |
| `reversed_color` | Color | (1.0, 0.4, 0.8) | Color when gravity reversed |
| `tint_duration` | float | 0.2 | Color transition time |
| `enable_particles` | bool | true | Burst particles on shift |
| `particle_amount` | int | 20 | Particle count per shift |
| `input_action` | StringName | "gravity_shift" | Input map action name |

### Signals (Connect to these)

```gdscript
# Emitted when gravity direction changes (after PlayerController applies it)
gravity_changed(is_reversed: bool, gravity_vector: Vector3)

# Emitted when shift starts (before physics change)
gravity_shift_started(is_reversed: bool)

# Emitted when shift completes (after physics change)
gravity_shift_completed(is_reversed: bool)
```

### Public API (Call from other scripts)

```gdscript
var gravity_comp = $GravityShiftComponent

# Query state
gravity_comp.is_gravity_reversed() -> bool
gravity_comp.get_gravity_vector() -> Vector3
gravity_comp.get_up_direction() -> Vector3
gravity_comp.get_state() -> Dictionary

# Force a specific gravity state (bypasses input/cooldown)
gravity_comp.force_shift(reversed: bool) -> bool

# Modify cooldown at runtime
gravity_comp.set_cooldown(time: float)

# Enable/disable the mechanic
gravity_comp.set_enabled(enabled: bool)
```

### Integration with PlayerController

The GravityShiftComponent **does not** directly modify `CharacterBody3D.gravity`. Instead:

1. Player presses input action (`gravity_shift` = Left Ctrl / Right Mouse Button)
2. Component validates (cooldown, grounded check, ceiling clearance)
3. Component calls `PlayerController.set_gravity_direction(new_direction)`
4. PlayerController:
   - Updates internal `_gravity_direction`
   - Projects velocity onto new gravity plane
   - Notifies CameraController via `on_gravity_changed()`
   - Emits `gravity_changed` signal
5. GravityShiftComponent receives signal, updates visual feedback
6. GravityShiftComponent emits `gravity_changed` for puzzle systems

**This respects the subsystem ownership boundary.**

### Input Map
Requires action `"gravity_shift"` (defined in project.godot):
- Key: Left Ctrl (Keycode 16777217)
- Mouse: Right Mouse Button (Button Index 2)

## Puzzle Interface: GravityAffected

Attach to any `Node3D` (RigidBody3D, CharacterBody3D, StaticBody3D) that should react to gravity changes.

### Configuration

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `gravity_source_path` | NodePath | "" | Explicit path to gravity source |
| `follow_gravity_direction` | bool | true | Align movement with gravity |
| `rotate_to_align` | bool | false | Smoothly rotate to match gravity |
| `rotation_speed` | float | 5.0 | Rotation interpolation speed |
| `apply_gravity_force` | bool | false | Apply force to RigidBody3D |
| `gravity_force_multiplier` | float | 1.0 | Force multiplier |
| `tint_on_shift` | bool | true | Color feedback |
| `normal_tint` / `reversed_tint` | Color | - | Visual colors |
| `tint_duration` | float | 0.3 | Transition time |

### Signals

```gdscript
gravity_affected_changed(is_reversed: bool, gravity_vector: Vector3)
```

### Auto-Detection Priority
1. Explicit `gravity_source_path` (if set)
2. Owner node's `GravityShiftComponent` child
3. Owner node if it's a `PlayerController`
4. Scene tree group `"gravity_shifter"` (first `GravityShiftComponent` or `PlayerController`)

### Manual Binding
```gdscript
var affected = $GravityAffected
affected.set_gravity_source(gravity_shift_component)
# OR
affected.set_gravity_source(player_controller)
```

## Gravity Volume: GravityVolume

Area3D that applies custom gravity to bodies inside. Use for localized puzzle zones.

### Configuration

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `gravity_vector` | Vector3 | DOWN * 9.8 | Gravity inside volume |
| `priority` | int | 0 | Higher wins on overlap |
| `affect_player` | bool | false | Affect player (usually false) |
| `affect_rigid_bodies` | bool | true | Affect RigidBody3D |
| `affect_character_bodies` | bool | true | Affect CharacterBody3D |
| `blend_distance` | float | 1.0 | Edge blend distance |
| `blend_time` | float | 0.5 | Transition duration |

### Signals

```gdscript
body_entered_gravity(body: Node3D, gravity_vector: Vector3)
body_exited_gravity(body: Node3D)
```

### Integration with GravityShiftable
Objects implementing `GravityShiftable` interface (has `apply_gravity_shift(Vector3)`) will receive the volume's gravity when entering.

## Testing

Run `scenes/main.tscn` - contains:
- Player with gravity shift (Left Ctrl / RMB)
- Floor, ceiling, and platforms at different heights
- Two gravity-affected cubes (RigidBody3D with GravityAffected)
- One gravity volume (purple box) with custom gravity

### Test Controls
- **WASD** - Move
- **Space** - Jump
- **Left Ctrl / RMB** - Gravity Shift
- **C** - Toggle First/Third Person
- **Escape** - Release Mouse

## Known Limitations

1. **CharacterBody3D ceiling detection**: `is_on_ceiling()` only works with `move_and_slide()`. The component uses raycast for ceiling clearance check.

2. **Velocity projection**: When gravity flips, `PlayerController.set_gravity_direction()` projects velocity onto the new gravity plane (removes vertical component). This prevents launching into ceiling but loses upward momentum.

3. **Mesh detection**: Color tint finds first `MeshInstance3D` in Player children. For complex models, ensure Player has a visible MeshInstance3D.

4. **Cooldown during shift**: Input during `shift_duration` is ignored. Rapid tapping won't queue shifts.

5. **Multiplayer**: Not networked. For MP, sync `_is_reversed` and call `force_shift()` on clients.

6. **GravityVolume + Player**: `affect_player = false` by default. Player gravity is controlled by GravityShiftComponent, not volumes.

## Minimal Integration Checklist

- [ ] Add `GravityShiftComponent` as child of Player node
- [ ] Set `player_controller_path` to `"."` (if Player has PlayerController script) or correct path
- [ ] Ensure `"gravity_shift"` action exists in Input Map (already in project.godot)
- [ ] (Optional) Add `GravityAffected` to puzzle objects - auto-detects Player
- [ ] (Optional) Add `GravityVolume` for puzzle zones
- [ ] (Optional) Implement `GravityShiftable` interface on custom objects for volume interaction

## Version Compatibility
- Godot 4.7.2+
- Uses `CharacterBody3D` APIs (4.0+)
- Uses `create_tween()` API (4.0+)
- Uses `GPUParticles3D` (4.0+)
- Compatible with existing `PlayerController` / `CameraController` architecture