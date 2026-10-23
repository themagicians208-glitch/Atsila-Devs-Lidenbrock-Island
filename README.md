# Skybound Showdown

<p align="center">
  <img src="branding/skybound-banner.svg" alt="Skybound Showdown — five sky-island obstacle courses" width="100%">
</p>

**Skybound Showdown** is a single-player 3D platform adventure made with Godot 4.7. Run, jump, and double-jump across five sky-island obstacle courses. Collect every coin, activate the switch, and reach the finish flag.

## Play

1. Install [Godot 4.7 or later](https://godotengine.org/download/).
2. Clone or download this repository.
3. Open the root `project.godot` file in Godot.
4. Press **F6** to run the home screen, or **F5** to run the project.

The project starts on the home screen, where you can start the adventure, select any course, or view the controls.

## Courses

| # | Course | Route and challenge |
| --- | --- | --- |
| 1 | Cloud Hop | Spiral climb across floating cloud platforms |
| 2 | Switchback Sprint | A wide S-shaped route with falling platforms |
| 3 | Moonflip Maze | Looping route with a mix of stable and crumbling platforms |
| 4 | Rising Ruins | Tight switchbacks that climb above the clouds |
| 5 | Sky Crown | The longest course, ending in a high zigzag ascent |

See [COURSES.md](COURSES.md) for course and mechanic notes.

## Controls

| Action | Keyboard |
| --- | --- |
| Move | W, A, S, D |
| Jump / double jump | Space |
| Freeze time briefly | F |
| Activate a nearby switch | E |
| Rotate camera | Arrow keys |
| Zoom camera | + / - |
| Return to home screen | Esc |

Each course requires collecting all coins, activating its switch, and touching the finish flag. Anti-gravity zones appear on selected courses; time freeze slows the whole game briefly and recharges after a cooldown.

## Build and export

Open the project in Godot and use **Project → Export** to create a build for your platform. Godot's matching export templates must be installed first. The Godot editor can be downloaded for free; no additional game-specific tools are required.

## Credits and licenses

The game builds on Kenney's Starter Kit 3D Platformer. See [LICENSE.md](LICENSE.md) for the starter project's MIT license. Included models, sprites, and sound effects retain their original asset credits and licenses; the Lilita font license is in [fonts/license.txt](fonts/license.txt).
