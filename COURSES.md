# Courses and mechanics

The five routes are generated in `scripts/main.gd`. Each course places its platforms, coins, finish flag, and course switch along a different path. Press **Q** to shift between Material and Mirror dimensions: Mirror platforms sit on an offset route, and selected obstacles appear in only one dimension.

| Course | Route shape | Course features |
| --- | --- | --- |
| Cloud Hop | Spiral climb | Offset mirror platforms, sky hoops, rotating sweepers, two falling platforms, anti-gravity zone |
| Switchback Sprint | Wide S-shaped path | Offset mirror platforms, jump hurdles, orange gates, two falling platforms, anti-gravity zone |
| Moonflip Maze | Tight hairpin turns | Offset mirror platforms, alternating material-phase wall openings, violet hoops, two falling platforms |
| Rising Ruins | Climbing switchbacks | Offset mirror platforms, broken columns, stone arches, rotating mirror-phase sweepers, two falling platforms, anti-gravity zone |
| Sky Crown | Long zigzag ascent | Offset mirror platforms, golden gates, rotating mirror-phase sweepers, crown spires, three falling platforms, anti-gravity zone |

## Shared course loop

1. Shift dimensions with **Q** to collect coins on both routes.
2. Shift to the Mirror dimension and reach its glowing switch; press **E**.
3. Reach the finish flag to complete the course.

Falling platforms collapse when the player lands on them in the Material dimension. Rotating sweepers block the Mirror path and must be timed or jumped. Maze walls block the Material path, requiring players to follow the alternating openings or shift dimensions; sprint hurdles can be jumped over. Anti-gravity zones reverse the player's gravity while they are inside. Press **F** to slow the whole game briefly; the ability recharges after a cooldown.

## Level progression

The home screen allows direct access to any course. Completing a course offers the next one; completing Sky Crown cycles back to Cloud Hop for another run.
