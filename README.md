# Liden Brock — PS01: GlitchVerse — The World Is Broken

**Artificial Arcade 2026 Entry** · Godot 4.7.2 · Single-player 3D survival-horror puzzle adventure

## Current direction

Liden Brock is a **strictly single-player campaign starring Samuel as the sole playable protagonist**. The current campaign target is five connected levels, culminating in a three-phase boss encounter and a rooftop SOS transmission.

> The campaign below is the design target, not a claim that all five levels are already implemented. Check the current scenes and the milestone checklist before treating a feature as complete.

## Campaign

1. **Shoreline Secrets** — storm-battered coast, yacht wreckage, debris-clearance lever puzzle, gravity tutorial, reality-switch tutorial, electrical generator puzzle, powered watchtower gate, and distress radio.
2. **The Overgrown Outpost** — greenhouse and field station, three-station hydraulic water-gate puzzle, timed power-grid rerouting, Power Cell, and Vacuum Tube Module.
3. **Shadows in the Canopy** — rainforest and containment pens, Stalker Strikers, security-monitor/keypad puzzle, and frequency calibration.
4. **Deep Sub-Level 3** — underground bio-labs, flooded corridors, Stalker Strikers, Chitin Heavyweights, Bio-Emitters, coolant-pressure sequence, tri-key logic puzzle, and Signal Amplifier.
5. **The Roof Transmission** — storm-lashed communications tower, transmitter assembly, controlled enemy waves, and Subject Zero's three-phase boss battle, followed by the SOS and extraction ending.

The full design and acceptance criteria are documented in [docs/CAMPAIGN_DESIGN.md](docs/CAMPAIGN_DESIGN.md).

## Mandatory world mechanics

- **Gravity reversal** — changes gameplay physics and traversal.
- **Time freeze** — temporarily freezes designated moving hazards or mechanisms while leaving player recovery and UI responsive.
- **Dimension/reality switching** — changes usable geometry, routes, or puzzle states, not just screen color.

All three mechanics must integrate with the same player, interaction, puzzle, objective, and restart systems.

## Level 1 priority

Complete and verify **Shoreline Secrets** as an end-to-end playable level before polishing the rest of the campaign. It must include the beach and wreckage, steel-bar debris puzzle, gravity and reality tutorials, equipment shed, copper-wire pickup, voltage-meter circuit puzzle, generator, power-dependent gate, radio broadcast, and transition to Level 2. Level 1 has no enemies.

## Controls

Current controls must be verified against `project.godot` and the in-game controls screen. Do not rely on this table if the input map changes during implementation.

| Action | Intended default |
|---|---|
| Move | WASD |
| Look | Mouse |
| Jump | Space |
| Interact | E |
| Gravity reversal | Q |
| Time freeze | F |
| Reality switch | R |
| Inventory | Tab or I |
| Pause | Esc |

## Visual direction

Aim for polished, readable, stylized 3D with the visual clarity of modern competitive games and a cinematic storm-survival atmosphere. This is a quality reference only; do not copy proprietary Valorant assets, characters, maps, or branding. Every used material, texture, shader, and scene reference must resolve, and graphics must be checked in a graphical run—not only headless tests.

## Development and verification

Open the project in **Godot 4.7.2** and run the main scene with F6/F5 as appropriate. Use the campaign design document's acceptance checklist and update it based on tests actually run. Do not report unimplemented or unverified features as complete.

- Preserve other contributors' work and uncommitted changes.
- Keep generated editor cache out of Git.
- Commit related, tested milestones with descriptive messages.
- Do not force-push or rewrite shared history.
