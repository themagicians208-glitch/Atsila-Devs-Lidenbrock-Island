# Liden Brock — PS01: GlitchVerse — The World Is Broken

**Artificial Arcade 2026** · **Godot 4.7.2** · **Single-player 3D survival horror / story-driven action-adventure**

## Overview

Liden Brock is a solo survival-horror campaign starring **Samuel**, the only playable protagonist. A violent ocean storm destroys his luxury yacht and leaves him stranded on a fog-shrouded, uncharted island. While searching for a way off the island, Samuel discovers an abandoned bio-engineering installation and the genetically modified bio-weapons left behind after a containment failure.

Samuel must explore the coast, jungle, drainage tunnels, and central facility; scavenge critical electronic modules; solve environmental, electrical, hydraulic, and logic puzzles; survive hostile creatures; assemble a long-range emergency transmitter; and send an SOS from the communications tower.

**This README describes the target design. It does not imply that every level or feature is already implemented.** See [docs/CAMPAIGN_DESIGN.md](docs/CAMPAIGN_DESIGN.md) for the canonical five-level campaign and acceptance checklist.

## Campaign progression

| Level | Name | Main objective | Challenge |
|---|---|---|---|
| 1 | **Shoreline Secrets** | Escape the yacht wreckage and repair a watchtower radio receiver | Tutorial exploration, debris lever, gravity/reality tutorials, generator circuit |
| 2 | **The Overgrown Outpost** | Recover the Vacuum Tube Module and Power Cell | Three-station hydraulic gate and timed power-grid rerouting |
| 3 | **Shadows in the Canopy** | Recover the Frequency Oscillator | Stalker Strikers, security-monitor/keypad puzzle, oscillator calibration and flare traps |
| 4 | **Deep Sub-Level 3** | Retrieve the Signal Amplifier and restore the central elevator | Flooded sectors, toxic spores, three enemy types, coolant pressure and tri-key logic |
| 5 | **The Roof Transmission** | Assemble and activate the transmitter, defeat Subject Zero, send SOS | Enemy swarms, defense turrets/traps, three-phase solo boss encounter and extraction ending |

## Samuel and solo gameplay

Samuel is the **sole playable character**. His strengths are tactical awareness, survival instincts, physical resourcefulness, and engineering under pressure. There is no character selection or co-op mode in this campaign design.

Core loop:
1. **Explore and scavenge** for transmitter components, tools, filters, ammunition, and useful supplies.
2. **Solve and reroute** environmental mechanisms, electrical circuits, water pressure, facility security, and signal calibration.
3. **Evade and fight** bio-weapons using stealth, traps, environmental counterplay, limited ammunition, and tactical positioning.
4. **Restore and transmit** by assembling the modular radio array, defending it during the rooftop assault, and sending the final SOS.

## Required reality mechanics

The game's “GlitchVerse — The World Is Broken” theme should be expressed through mechanics, not only visual effects:

- **Gravity reversal:** changes gameplay physics and traversal, with safe landing and recovery behavior.
- **Time freeze:** temporarily freezes designated moving hazards or mechanisms while player control, UI, and recovery remain responsive.
- **Dimension/reality switching:** changes usable geometry, collision, routes, machinery, or puzzle states—not just the screen's color.

These abilities must integrate with the same player controller, interactions, puzzles, objectives, and restart/checkpoint systems. Their implementation status must be verified in the actual project.

## Enemy bestiary

- **Stalker Strikers:** fast, agile ambushers that use rainforest foliage, ceilings, fog, and darkness to stalk Samuel.
- **Chitin Heavyweights:** armored juggernauts requiring environmental hazards, exposed weak points, or concentrated heavy damage.
- **Bio-Emitters:** dangerous mutated subjects that release toxic spore clouds or disorienting bioluminescent flashes.
- **Subject Zero — The Apex Chimera:** the final boss with three distinct phases: Brute, Shadow, and Frenzy.

## Transmitter components

Samuel must recover and combine the **Vacuum Tube Module**, **Power Cell**, **Frequency Oscillator**, and **Signal Amplifier**. Each level's puzzle progression should make the component's purpose clear and update the objective state only after a valid pickup or successful interaction.

## Art and audio direction

Aim for polished, readable 3D environments with strong silhouettes, cinematic storm lighting, dense rainforest, a derelict bio-engineering facility, readable interactables, and impactful sound. Modern competitive-game clarity may be used as a quality reference, but do not copy proprietary Valorant assets, characters, maps, textures, or branding. Use original or properly licensed assets. All resource references and shaders must resolve and be checked in a graphical run.

## Development and verification

- Open and test with **Godot 4.7.2**.
- Audit existing scenes, scripts, and Git status before editing; preserve contributors' work and uncommitted changes.
- Prioritize an end-to-end playable Level 1, then implement the remaining levels and final encounter.
- Report separately what is **designed**, **implemented**, **automated-tested**, and **visually/manual-tested**.
- Do not label a feature complete solely because it appears in this document.
- Keep generated editor cache, secrets, and temporary logs out of Git.
- Commit related, tested milestones with descriptive messages. Never force-push or rewrite shared history.
