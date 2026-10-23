# Courses and mechanics

The five routes are generated in `scripts/main.gd`. Each course places its platforms, coins, finish flag, and course switch along a different path.

| Course | Route shape | Course features |
| --- | --- | --- |
| Cloud Hop | Spiral climb | Mixed platform sizes and two falling platforms |
| Switchback Sprint | Wide S-shaped path | Alternating platform sizes, two falling platforms, anti-gravity zone |
| Moonflip Maze | Looping path | Mixed platform sizes and three falling platforms |
| Rising Ruins | Tight climbing switchbacks | Varied platforms, two falling platforms, anti-gravity zone |
| Sky Crown | Long zigzag ascent | Varied platforms, three falling platforms, anti-gravity zone |

## Shared course loop

1. Collect every coin on the route.
2. Reach the glowing switch and press **E**.
3. Reach the finish flag to complete the course.

Falling platforms collapse when the player lands on them. Anti-gravity zones reverse the player's gravity while they are inside. Press **F** to slow the whole game briefly; the ability recharges after a cooldown.

## Level progression

The home screen allows direct access to any course. Completing a course offers the next one; completing Sky Crown cycles back to Cloud Hop for another run.
