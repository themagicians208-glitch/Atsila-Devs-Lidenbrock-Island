# Liden Brock — Campaign Design and Implementation Contract

**Project:** Artificial Arcade 2026, PS01 — “GlitchVerse: The World Is Broken”  
**Engine:** Godot 4.7.2  
**Mode:** Single-player only  
**Playable protagonist:** Samuel only

This document is the current design source of truth. The campaign is a target specification; feature completion must be verified against the actual project and tests. Do not infer implementation from this document alone.

## Core premise

Samuel survives a yacht disaster on an uncharted, storm-battered island. He must navigate the coast and abandoned facilities, recover transmitter components, uncover the consequences of secret bioengineering experiments, and send an SOS. The island's unstable systems introduce gravity reversal, time freeze, and dimension/reality switching. The campaign ends with a rooftop transmission and extraction.

Samuel is a tall, muscular, masculine adult survivor with practical survival/tactical clothing. He is the only playable character. Other characters, if present in story content, are non-playable and are not character-selection options.

## Required mechanics from the problem statement

### Gravity reversal
A real physics/traversal mechanic that changes the direction of gravity. It must handle velocity, character orientation or gravity-relative movement, collision, landing, affected puzzle objects, and level restart safely. Visual feedback is required.

### Time freeze
A temporary ability that freezes designated moving mechanisms or hazards. The player, ability release, UI, and recovery logic must remain responsive. Frozen objects must resume safely and cooldown/duration must be communicated.

### Dimension/reality switching
Two meaningfully different states of the environment. Switching must change actual usable geometry, collision, routes, machinery, or puzzle states—not only apply a color filter. Prevent the player from being embedded in geometry or trapped by a switch.

All three mechanics are mandatory. Introduce them in a safe, understandable way in Level 1 and expand their puzzle applications in later levels.

## Campaign overview

| Level | Name | Primary goal | Main gameplay |
|---|---|---|---|
| 1 | Shoreline Secrets | Escape the wreckage, repair the watchtower generator/radio, locate the central complex | Tutorial exploration, debris lever, gravity and reality tutorials, electrical circuit puzzle; no enemies |
| 2 | The Overgrown Outpost | Recover the Power Cell and Vacuum Tube Module | Greenhouse, hazards, hydraulic gate, three valve stations, timed power-grid rerouting |
| 3 | Shadows in the Canopy | Recover the Frequency Oscillator | Rainforest stealth, Stalker Strikers, containment keypad override, frequency calibration |
| 4 | Deep Sub-Level 3 | Recover the Signal Amplifier and restore the central elevator | Flooded bio-labs, toxic spores, Stalker Strikers, Chitin Heavyweights, Bio-Emitters, coolant-pressure and tri-key logic puzzles |
| 5 | The Roof Transmission | Assemble transmitter, broadcast SOS, survive and defeat Subject Zero | Controlled enemy waves, electrical nodes, floodlights, three-phase boss fight, ending |

## Level 1 — Shoreline Secrets

**Setting:** Storm-battered coast, yacht wreckage, cliff route, equipment shed, abandoned perimeter watchtower.  
**Difficulty:** Tutorial. **Enemies:** None.

### Required progression

1. **Opening:** Show the storm-damaged coast and wreckage, establish Samuel's immediate goal, then return control promptly.
2. **Beach exploration:** Traversable beach, debris, rocks, driftwood, readable route, useful landmarks, optional exploration reward.
3. **Debris Clearance:** A collapsed timber/shipwreck obstruction blocks the cliff route. Samuel finds and collects a steel bar, uses it as a lever at a valid interaction point, and physically or convincingly moves the obstruction. The route and objective state update only after success.
4. **Gravity tutorial:** Samuel uses gravity reversal in a safe designated area to reach an elevated platform or retrieve a component. The mechanic changes gameplay physics and can be restored safely.
5. **Reality-switch tutorial:** A damaged route is unavailable in one reality. Switching reveals or enables an actual route, platform, or connection with correct collision. The player completes the puzzle and returns to a valid state.
6. **Equipment shed:** A small navigable shed contains scrap copper wire and a voltage meter. Both are picked up through real interactions and reflected in inventory/objectives.
7. **Circuit Jump Starter:** Samuel inspects the damaged generator, uses the voltage meter, and configures a breaker/circuit panel with at least two independently configurable loads or paths. Readable voltage/load clues support a deterministic solution. Incorrect configurations give feedback and do not start the generator; hints may follow repeated failures.
8. **Power restoration:** The correct circuit starts the generator and visibly powers lights/machinery. The watchtower gate opens only when its power prerequisite is satisfied.
9. **Radio receiver:** Samuel enters the watchtower and activates the receiver. A real audio/text broadcast points him toward the island's central complex.
10. **Completion:** Show completed objectives and a working Continue action to Level 2. Restart must restore puzzle, objective, inventory, and interactable states consistently.

The electrical puzzle must require a meaningful configuration, not repeated button presses or an unconditional success trigger. The player must be able to finish without external documentation.

## Level 2 — The Overgrown Outpost

**Setting:** Abandoned botanical greenhouse and peripheral field station.  
**Goal:** Recover a high-capacity Power Cell and Vacuum Tube Module; clear the jungle trail.

- Environmental hazards: slippery mudslides, steam leaks, collapsing catwalks.
- **Hydraulic Water Gate:** Three separated valve stations and readable pressure gauges. Track valve states and pressure; lower the flooded lock only when the actual pressure conditions are met.
- **Power Grid Rerouting:** Configure a breaker and timed relay switches, then use a fair time window to reach sub-switches. Provide readable feedback and a recoverable reset.
- Recover both required components and transition to Level 3.

## Level 3 — Shadows in the Canopy

**Setting:** Fog-laden rainforest and ruined containment pens.  
**Goal:** Recover the Frequency Oscillator and retreat through drainage tunnels.

- Introduce **Stalker Strikers**, fast bio-weapons that stalk, detect, pursue, attack, search, and recover through a real AI state machine.
- **Containment Lock Override:** Security monitors reveal clues to keypad codes. Validate codes and control functional doors while the player avoids enemies.
- **Frequency Calibration:** Tune a rusted oscillator using visual waveform/frequency feedback. Flare traps or equivalent defenses can delay/repel Stalkers.
- The ambush/retreat must lead into Level 4 without breaking progression.

## Level 4 — Deep Sub-Level 3

**Setting:** Subterranean bio-labs, flooded maintenance corridors, containment vaults.  
**Goal:** Retrieve the Signal Amplifier and restore the central elevator.

- **Stalker Strikers:** Fast ambush enemies.
- **Chitin Heavyweights:** Armored juggernauts with distinct resistance and counterplay.
- **Bio-Emitters:** Release dangerous spore clouds; hazards have readable boundaries and fair counterplay.
- **Coolant Pressure Balance:** Four flooded sectors, timed sequence, valves operated in the required reverse order, pressure state tracked, and protective filters/masks where required.
- **Tri-Key Encryption Deck:** Three terminal nodes with actual logic/code validation. Lockdowns must be recoverable rather than permanently soft-locking the campaign.
- Retrieve the Signal Amplifier, restore elevator power, and transition to Level 5.

## Level 5 — The Roof Transmission

**Setting:** Communications tower rooftop in a tropical storm.  
**Goal:** Assemble the transmitter, broadcast the distress signal, survive, and defeat Subject Zero.

- Build a navigable rooftop arena with power nodes, floodlights, transmitter, defensible positions, clear attack telegraphs, and valid enemy spawn locations.
- Enemy waves may pressure Samuel while he works, but spawning must be controlled so the encounter is guaranteed winnable.
- The transmitter and all boss-phase objectives must use real gameplay state.

### Subject Zero — The Apex Chimera

A large apex predator with chitinous armor, bioluminescent camouflage, and heavy/fast attacks. It has a real health system, collision, damage reactions, defeat state, and three distinct phases.

1. **Brute:** Charges and ground slams; ordinary attacks are resisted. Samuel overloads rooftop power nodes and lures the boss into exposed conduits to strip armor and expose the core.
2. **Shadow:** Camouflage and spore hazards reduce visibility. Samuel restores generator breakers and floodlights to reveal the boss and create attack windows.
3. **Frenzy:** Faster attacks and pressure from minions. Samuel uses a functional Tactical Focus ability for a bounded combat advantage and completes final transmitter adjustments.

Each phase must transition correctly. Boss defeat must trigger the ending; death/recovery must not duplicate or permanently break the encounter.

## Ending

After Subject Zero falls from the rooftop, Samuel completes the transmitter, activates the final switch, and sends an encrypted SOS. The facility collapses; a helicopter arrives through the storm; Samuel escapes and looks back at the burning island. Use the actual character/environment, avoid camera or animation lockups, offer a skip option where practical, then show credits/end screen and a way back to the main menu.

## Visual and audio direction

Target polished, readable stylized 3D with deliberate silhouettes and color design inspired by modern competitive-game clarity, paired with cinematic survival-horror lighting. Valorant is a quality reference only; do not copy its proprietary assets, characters, maps, textures, or branding.

Required environmental materials include wet/dry sand, rocks, cliff, timber, rusted metal, copper, concrete, glass, machinery, foliage, water, and emissive circuitry. Use compatible shaders for water/wet surfaces, electrical emission, reality transitions, and gravity/time effects as appropriate. Every used resource must resolve and every shader must compile. Add storm, ocean, rain, wind, generator, interaction, radio, mechanic, enemy, combat, and victory audio using licensed or original alternatives. Headless checks do not count as visual QA.

## Engineering and project safety

- Work inside the existing Godot 4.7.2 project and audit files/Git status before edits.
- Preserve useful scenes/scripts and all unrelated uncommitted work.
- Samuel is the only playable character; no multiplayer, co-op, character selection, or switching.
- Reuse existing managers and contracts; avoid duplicate autoloads, conflicting class names, stale node references, and duplicate signal connections.
- Use valid collision, interaction range, scene transitions, checkpoints, restart, and objective states.
- Do not add TODO/placeholder implementations for mandatory features.
- Do not commit editor cache, secrets, or temporary logs.
- Do not commit/push unless the contributor/workflow authorizes it; never force-push or rewrite shared history.

## Verification checklist

- [ ] Project and main scene load in Godot 4.7.2; scripts/resources/shaders validate.
- [ ] Main menu, settings, pause, restart, and transitions work.
- [ ] Samuel's controller, collision, camera, interaction, inventory, and objectives work.
- [ ] Gravity reversal changes gameplay and recovers safely.
- [ ] Time freeze affects designated objects without freezing recovery/UI.
- [ ] Reality switching changes geometry/collision/puzzle state and cannot trap the player.
- [ ] Level 1 can be completed from opening to radio broadcast.
- [ ] Steel-bar debris puzzle has real prerequisites and success state.
- [ ] Copper wire and voltage meter pickups work.
- [ ] Circuit puzzle rejects invalid configurations and powers gate only on success.
- [ ] Radio broadcast and Continue transition work.
- [ ] Levels 2–5 contain the required puzzles, hazards, items, and progression.
- [ ] Enemy AI, damage, death, checkpoint, and recovery work.
- [ ] Subject Zero phases and defeat are winnable and stable.
- [ ] SOS and ending work.
- [ ] Graphical run checks character, materials, lighting, shader behavior, UI, collision alignment, and performance.
- [ ] Final report separates implemented, tested, visually verified, and still-unverified items.

A design requirement is not proof of implementation. Update status only after the corresponding feature is present and verified.
