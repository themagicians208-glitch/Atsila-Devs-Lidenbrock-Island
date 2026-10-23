# Liden Brock Level 1 - UI Integration Guide

## Overview
This document describes the signals and APIs that game systems must implement for the UI to function correctly. The UI is implemented as a set of Godot Control nodes managed by a `UIManager` autoload.

## UIManager (Autoload)
Add `ui/scripts/ui_manager.gd` as an Autoload singleton named `UIManager`.

### UIManager Signals (emitted by UI, connect in game systems)
```gdscript
signal main_menu_play_pressed
signal main_menu_quit_pressed
signal pause_menu_resume_pressed
signal pause_menu_restart_pressed
signal pause_menu_main_menu_pressed
signal victory_screen_continue_pressed
```

### UIManager Methods (call from game systems)
```gdscript
func show_main_menu()
func hide_main_menu()
func show_hud()
func hide_hud()
func show_pause_menu()
func hide_pause_menu()
func show_victory_screen(final_score: int, completion_time: float, collectibles_found: int, collectibles_total: int)
func hide_victory_screen()
func show_failure_message(message: String, is_stuck: bool = false)
func hide_failure_message()
func update_score(score: int)
func update_collectibles(found: int, total: int)
func update_objective(text: String)
func update_gravity_shift(status: String, cooldown: float = 0.0, max_cooldown: float = 1.0)
func show_interaction_prompt(text: String)
func hide_interaction_prompt()
func set_control_hints(visible: bool)
```

## Required Game Signals (emitted by game systems, connect in UIManager or game manager)

### Player / Gameplay Signals
```gdscript
# Emitted when player score changes
signal score_changed(new_score: int)

# Emitted when collectible count changes
signal collectibles_changed(found: int, total: int)

# Emitted when current objective updates
signal objective_changed(text: String)

# Emitted when gravity shift state changes
# status: "READY" | "ACTIVE" | "COOLDOWN" | "DISABLED"
signal gravity_shift_changed(status: String, cooldown: float, max_cooldown: float)

# Emitted when player can interact with something
signal interaction_available(prompt_text: String)

# Emitted when interaction is no longer available
signal interaction_unavailable()

# Emitted when player dies/falls
signal player_failed(message: String, is_stuck: bool = false)

# Emitted when level is completed
signal level_completed(final_score: int, completion_time: float, collectibles_found: int, collectibles_total: int)
```

### Pause / Menu Signals
```gdscript
# Emitted when player presses pause key (Esc)
signal pause_requested

# Emitted when player requests unpause
signal resume_requested
```

## Integration Example (Game Manager)

```gdscript
# In your main game manager script
extends Node

@onready var ui_manager = UIManager

func _ready() -> void:
	# Connect UI signals to game logic
	ui_manager.main_menu_play_pressed.connect(_on_play_pressed)
	ui_manager.main_menu_quit_pressed.connect(_on_quit_pressed)
	ui_manager.pause_menu_resume_pressed.connect(_on_resume_pressed)
	ui_manager.pause_menu_restart_pressed.connect(_on_restart_pressed)
	ui_manager.pause_menu_main_menu_pressed.connect(_on_main_menu_pressed)
	ui_manager.victory_screen_continue_pressed.connect(_on_victory_continue)
	
	# Connect game signals to UI
	score_changed.connect(ui_manager.update_score)
	collectibles_changed.connect(ui_manager.update_collectibles)
	objective_changed.connect(ui_manager.update_objective)
	gravity_shift_changed.connect(ui_manager.update_gravity_shift)
	interaction_available.connect(ui_manager.show_interaction_prompt)
	interaction_unavailable.connect(ui_manager.hide_interaction_prompt)
	player_failed.connect(ui_manager.show_failure_message)
	level_completed.connect(ui_manager.show_victory_screen)
	
	# Start with main menu
	ui_manager.show_main_menu()

func _on_play_pressed() -> void:
	ui_manager.hide_main_menu()
	ui_manager.show_hud()
	start_new_game()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_resume_pressed() -> void:
	ui_manager.hide_pause_menu()
	resume_game()

func _on_restart_pressed() -> void:
	ui_manager.hide_pause_menu()
	restart_level()

func _on_main_menu_pressed() -> void:
	ui_manager.hide_pause_menu()
	ui_manager.hide_hud()
	return_to_main_menu()

func _on_victory_continue() -> void:
	ui_manager.hide_victory_screen()
	load_next_level()

func _on_player_pause() -> void:
	ui_manager.show_pause_menu()
	pause_game()

# Call these from your gameplay systems:
func on_score_changed(points: int) -> void:
	score_changed.emit(current_score)

func on_collectible_collected() -> void:
	collectibles_changed.emit(found_count, total_count)

func on_objective_update(text: String) -> void:
	objective_changed.emit(text)

func on_gravity_shift_status(status: String, cooldown: float, max_cooldown: float) -> void:
	gravity_shift_changed.emit(status, cooldown, max_cooldown)

func on_interaction_enter(prompt: String) -> void:
	interaction_available.emit(prompt)

func on_interaction_exit() -> void:
	interaction_unavailable.emit()

func on_player_death(message: String = "SYSTEM FAILURE", is_stuck: bool = false) -> void:
	player_failed.emit(message, is_stuck)

func on_level_win(score: int, time: float, found: int, total: int) -> void:
	level_completed.emit(score, time, found, total)
```

## Gravity Shift Status Values
| Status | Description | Color |
|--------|-------------|-------|
| `READY` | Available to use | Green |
| `ACTIVE` | Currently shifting gravity | Yellow/Orange |
| `COOLDOWN` | Recharging | Red/Orange |
| `DISABLED` | Unavailable in current context | Gray |

## Theme
All UI uses `ui/themes/ui_theme.tres` - a cinematic corrupted virtual-world theme with:
- Dark purple/black backgrounds with magenta/cyan accents
- Glowing borders and shadows
- Outlined text for readability
- Smooth animations on hover/press

## Resolution Independence
- All UI uses anchors and containers for scaling
- Minimum font size: 18px (control hints), 22px (body), 24px+ (headers)
- Tested at 1920x1080, 2560x1440, 3840x2160
- Safe margins: 20px from edges

## Input Handling
- Keyboard: WASD/Arrows, Space, Shift, G, E, Esc
- Mouse: Full button interaction support
- Gamepad: Not yet implemented (add to control hints if needed)

## File Structure
```
ui/
├── scripts/
│   ├── ui_manager.gd       # Autoload singleton
│   ├── main_menu.gd
│   ├── hud.gd
│   ├── pause_menu.gd
│   ├── victory_screen.gd
│   └── failure_message.gd
├── scenes/
│   ├── main_menu.tscn
│   ├── hud.tscn
│   ├── pause_menu.tscn
│   ├── victory_screen.tscn
│   └── failure_message.tscn
├── themes/
│   └── ui_theme.tres
└── INTEGRATION_GUIDE.md    # This file
```

## Testing Checklist
- [ ] Main menu opens on game start
- [ ] Play button starts game, shows HUD
- [ ] Quit button closes application
- [ ] HUD shows score, collectibles, gravity shift, objective
- [ ] Interaction prompt appears/disappears correctly
- [ ] Pause menu opens on Esc, pauses game
- [ ] Resume closes pause menu, unpauses game
- [ ] Restart reloads current level
- [ ] Main Menu returns to main menu
- [ ] Victory screen shows on level complete with stats
- [ ] Failure message shows on death/stuck
- [ ] All text readable at 1080p, 1440p, 4K
- [ ] No UI blocks 3D view during gameplay