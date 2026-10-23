# Level 1 puzzle integration

Puzzle-owned scenes implement the existing contract in `ARCHITECTURE_CONTRACT.md`:

- `PhysicsCrate`: `can_interact(interactor)`, `interact(interactor)`, `get_prompt()`, and `apply_gravity_shift(new_gravity)`. After interaction, it listens to the verified player `gravity_shifted(new_gravity)` success signal; inverted gravity moves the crate to the plate target. It does not poll gravity input.
- `PressurePlate`: emits `activated(activator)` once while occupied and unlocks the grouped `ExitDoor`.
- `ExitDoor`: `unlock()` and one-shot `level_completed("level_01", score, time)` forwarding to `LevelManager`.
- `PuzzleCollectible`: emits `collected(value)` and calls `ScoreManager.add(value)` once.

The existing Level 1 scene already instances these puzzle-owned scenes. The crate publishes the objective through the existing HUD API; the plate changes it to the open-exit objective. Restart is scene reload plus the existing `ScoreManager.reset()`, and each puzzle node also exposes `reset_puzzle()` for direct test/reset use.

