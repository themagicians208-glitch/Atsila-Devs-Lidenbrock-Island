# Liden Brock — Five-Level Solo Campaign Design

**Event:** Artificial Arcade 2026 · PS01 — “GlitchVerse: The World Is Broken”  
**Engine:** Godot 4.7.2  
**Mode:** Single-player only  
**Playable protagonist:** Samuel only

This document is the canonical design target for the campaign. It specifies the intended experience; it is not proof that the content is already implemented. Verify the actual scenes, scripts, assets, and playable build before reporting completion.

## High concept and narrative

A violent ocean storm destroys Samuel's luxury yacht and strands him on a fog-shrouded, uncharted island. He discovers a vast, overgrown research complex that was secretly developing genetically modified bio-weapons. Following a catastrophic containment failure, the creatures now roam the island and abandoned facility.

With no cellular reception and no reliable way to contact the outside world, Samuel must survive the coast, greenhouse outpost, rainforest, subterranean bio-labs, and rooftop communications tower. He recovers four key transmitter modules, solves systems puzzles, and assembles a long-range emergency radio. The final transmission requires him to withstand a rooftop assault and defeat Subject Zero before a rescue helicopter extracts him.

Samuel is the only playable character. The design emphasizes solo survival instincts, tactical awareness, engineering resourcefulness, and problem-solving under pressure. Do not add co-op, multiplayer, character selection, or character switching.

## Campaign at a glance

| Level | Name | Primary objective | Difficulty |
|---|---|---|---|
| 1 | Shoreline Secrets | Escape the wreckage and repair the watchtower receiver | Tutorial |
| 2 | The Overgrown Outpost | Recover the Vacuum Tube Module and Power Cell | Low–medium |
| 3 | Shadows in the Canopy | Find the Frequency Oscillator and retreat underground | Medium |
| 4 | Deep Sub-Level 3 | Retrieve the Signal Amplifier and restore the central elevator | Hard |
| 5 | The Roof Transmission | Assemble the transmitter, send SOS, defeat Subject Zero, escape | Climax |

## Mandatory GlitchVerse mechanics

### Gravity reversal
A real traversal/physics ability that changes gravity direction. It must handle velocity, player orientation or gravity-relative movement, collision, landing, puzzle objects where applicable, and level restart safely. Give clear visual and audio feedback.

### Time freeze
Temporarily freezes designated moving hazards or mechanisms. Player control, UI, ability release, and recovery must remain responsive. Communicate duration/cooldown and resume frozen objects safely.

### Dimension/reality switching
Provide meaningfully different environmental states. Switching must change usable geometry, collision, routes, machinery, or puzzle states—not merely apply a color filter. Prevent the player from becoming embedded in geometry or trapped by a switch.

Introduce the mechanics safely in Level 1 and expand their puzzle use in later levels. They must integrate with the player, interactions, objectives, and restart/checkpoint flow.

---

## Level 1 — Shoreline Secrets

**Setting:** Storm-battered coast, yacht wreckage, cliff path, equipment shed, abandoned perimeter watchtower.  
**Difficulty:** Tutorial. **Enemies:** None.  
**Primary goal:** Escape the wreckage and repair the watchtower receiver to locate the central complex.

### Progression and puzzles

1. **Opening:** Establish the storm aftermath and Samuel's immediate survival goal, then return control promptly.
2. **Beach exploration:** Create a traversable beach with yacht debris, rocks, driftwood, readable landmarks, and a clear route toward the cliff.
3. **Debris Clearance:** A collapsed timber/shipwreck obstruction blocks the path. Samuel finds a steel bar and uses it as a lever at a valid interaction point to move the obstruction. Update the route/objective only after success.
4. **Gravity tutorial:** Samuel reverses gravity in a safe area to reach an elevated platform or retrieve a component, then returns to a safe state.
5. **Reality-switch tutorial:** A route unavailable in one reality becomes usable in another through real geometry/collision or route changes. Samuel completes the traversal and returns to a valid state.
6. **Equipment shed:** A navigable shed contains scrap copper wire and a voltage meter. Pickups must use real interactions and update inventory/objectives.
7. **Circuit Jump Starter:** Samuel inspects a damaged generator, uses the voltage meter, and configures a breaker/circuit panel with at least two independently configurable loads or paths. Readable voltage/load clues support a deterministic solution. Incorrect configurations must fail with useful feedback; hints may follow repeated failures.
8. **Power restoration:** The correct circuit starts the generator and visibly powers lights or machinery. The watchtower gate opens only when the power prerequisite is satisfied.
9. **Radio receiver:** Samuel enters the watchtower and activates the receiver. A broadcast points him toward the island's central complex.
10. **Completion:** Show completed objectives and a working Continue action to Level 2. Restart must restore puzzle, inventory, objective, and interactable states consistently.

The electrical puzzle must require a meaningful configuration, not repeated button presses or unconditional success. The player must be able to solve it without external documentation.

## Level 2 — The Overgrown Outpost

**Setting:** Abandoned botanical greenhouse and peripheral field station.  
**Primary goal:** Recover a high-capacity Power Cell and Vacuum Tube Module, then clear the main jungle trail.  
**Threats:** Environmental hazards only—slippery mudslides, scalding steam leaks, and collapsing catwalks.

### Required puzzles

- **Hydraulic Water Gate:** Three separated valve stations with readable pressure gauges. Samuel tracks pressure and adjusts the valves; the flooded lock lowers and reveals a key security card only when the actual pressure conditions are correct.
- **Power Grid Rerouting:** Samuel configures a main breaker and timed relay switches. The window must be short enough to demand route planning but fair enough to complete. Provide readable feedback and a recoverable reset after failure.
- Recover both the **Vacuum Tube Module** and **Power Cell**, update objectives, and open the main trail to Level 3.

## Level 3 — Shadows in the Canopy

**Setting:** Dense, fog-laden rainforest and ruined containment pens.  
**Primary goal:** Find the Frequency Oscillator and retreat through the drainage tunnels.  
**Enemy introduced:** **Stalker Strikers**—fast, agile bio-weapons that stalk Samuel from the canopy and strike from fog or darkness.

### Required puzzles and stealth

- **Containment Lock Override:** Security monitors reveal clues needed to map keypad codes. Samuel moves between terminals and locked pens, validates the codes, and avoids Stalkers.
- **Frequency Calibration:** Samuel manually tunes a rusted oscillator using visual waveform/frequency indicators. The feedback must make the correct tuning discoverable.
- **Flare traps:** Samuel can place or activate defensive flare traps to delay or repel Stalkers and create puzzle-solving windows.
- Retrieve the **Frequency Oscillator**. A sudden Stalker ambush forces Samuel to retreat underground into the facility's drainage tunnels and leads into Level 4.

## Level 4 — Deep Sub-Level 3

**Setting:** Subterranean bio-labs, flooded maintenance corridors, and containment vaults.  
**Primary goal:** Retrieve the Signal Amplifier and restore power to the central facility elevator.

### Enemies

- **Stalker Strikers:** Fast ambushers.
- **Chitin Heavyweights:** Armored juggernauts with distinct resistance and environmental counterplay.
- **Bio-Emitters:** Release blinding or toxic spore clouds. Hazards need readable boundaries and fair counterplay, including protective filters/masks where required.

### Required puzzles

- **Coolant Pressure Balance:** A timed sequence across four flooded sectors. Samuel operates valves in the required reverse order while tracking pressure and managing toxic spore exposure. The sequence must be understandable, resettable, and winnable.
- **Tri-Key Encryption Deck:** Three terminal nodes with real logic/code validation. Time pressure and facility security can trigger a lockdown or release a Chitin Heavyweight, but the puzzle must not permanently soft-lock the campaign.
- Recover the **Signal Amplifier**, restore elevator power, and ride the central elevator to Level 5.

## Level 5 — The Roof Transmission

**Setting:** Rooftop communications tower during an intense tropical storm.  
**Primary goal:** Assemble the emergency transmitter, broadcast the distress signal, survive the assault, and complete extraction.

### Rooftop combat loop

- Build a navigable arena containing the transmitter, power nodes, floodlights, generator breakers, vents, defensible positions, and clear enemy spawn points.
- **Solo survival pressure:** Stalkers and Bio-Emitters continuously assault the roof. The design calls for respawning swarms; spawn pacing and recovery must keep the encounter technically completable rather than allowing an unavoidable spawn-lock.
- Samuel manages ammunition, uses stationary defense turrets/traps, and balances transmitter repairs with combat.
- Boss-phase objectives and transmitter assembly must use actual gameplay state, not cinematic-only triggers.

### Final boss — Subject Zero, the Apex Chimera

A massive, hyper-genetically modified apex predator with chitinous plating, bioluminescent camouflage, brute force, and distinct attacks. It needs real health, collision, damage reactions, phase transitions, defeat state, and recoverable death/restart handling.

#### Phase 1 — Brute (Armor and force)
**Behavior:** Subject Zero charges Samuel, smashes structural pillars, and resists ordinary firearm attacks.

**Counterplay:** Samuel manually overloads rooftop power nodes and lures the boss into exposed high-voltage conduits. Successful hits strip its chitinous armor and expose its core to direct weapon fire. Telegraph charges and provide safe, readable counterplay windows.

#### Phase 2 — Shadow (Camouflage and spores)
**Behavior:** Subject Zero activates bioluminescent camouflage, blending into rain and storm haze while Bio-Emitters create thick spore clouds.

**Counterplay:** Samuel navigates low visibility, restores generator breakers, and powers perimeter floodlights. Intense light breaks the camouflage and opens a precision-attack window. Spore exposure needs clear feedback and a fair way to recover.

#### Phase 3 — Frenzy (Total assault)
**Behavior:** Subject Zero moves faster, chains rapid attacks, ignores electrical traps, and is joined by a continuous minion assault.

**Counterplay:** Samuel activates **Tactical Focus**, a bounded ability that slows perceived combat time/reaction pressure, boosts damage, and reduces weapon recoil for a limited window. He uses heavy suppression fire, manages ammunition, survives the swarm, and completes the final transmitter adjustments.

All three phases must be distinct and transition only when their actual conditions are met. Boss defeat must reliably unlock the ending; death/restart must not duplicate or permanently break the encounter.

## Cinematic ending

After Subject Zero falls from the rooftop, Samuel slams the final ignition switch on the radio tower. The automated beacon sends an encrypted SOS through the storm. A rescue helicopter breaks through the rain and lowers an extraction line while the facility's sub-levels collapse. Samuel clips on, looks back at the burning island, and is carried into the storm clouds.

The ending should use the actual character/environment, avoid camera or animation lockups, offer a skip option where practical, and finish on a credits/end screen with a way back to the main menu.

## Visual and audio direction

Target polished, modern, readable 3D: strong silhouettes, cinematic storm lighting, wet coastal surfaces, dense rainforest, derelict bioengineering spaces, reactive machinery, and clear interactive-object readability. Valorant may be a high-level visual-clarity reference only; do not copy its proprietary assets, characters, maps, textures, or branding.

Use original or properly licensed assets. Materials should cover wet/dry sand, rock, timber, rusted metal, copper, concrete, glass, foliage, water, and emissive circuitry. Suitable original shaders/effects can support water/wetness, electricity, reality transitions, gravity, and time freeze. Every resource must resolve and every shader must compile. Include storm/ocean/rain/wind, generator, interaction, radio, mechanic, enemy, combat, and victory audio. Headless checks alone are not visual QA.

## Engineering and project safety

- Work inside the existing Godot 4.7.2 project and inspect files/Git status before edits.
- Preserve useful scenes/scripts and all unrelated uncommitted work.
- Samuel is the only playable character; no multiplayer, co-op, character selection, or switching.
- Reuse existing managers and contracts; avoid duplicate autoloads, conflicting class names, stale node references, and duplicate signal connections.
- Ensure valid collision, interaction range, objective progression, inventory, scene transitions, checkpoints, restart, and recovery.
- Do not use TODOs or placeholder logic for mandatory features.
- Do not commit editor cache, secrets, or temporary logs.
- Never force-push or rewrite shared history.

## Verification checklist

- [ ] Project and main scene load in Godot 4.7.2; scripts and resources validate.
- [ ] Main menu, settings, pause, restart, and level transitions work.
- [ ] Samuel's controller, camera, collision, interaction, inventory, and objectives work.
- [ ] Gravity reversal changes gameplay and recovers safely.
- [ ] Time freeze affects designated objects without freezing player recovery/UI.
- [ ] Reality switching changes geometry/collision/puzzle state and cannot trap the player.
- [ ] Level 1 can be completed from opening through the radio broadcast.
- [ ] Steel-bar debris puzzle has real prerequisites and a success state.
- [ ] Copper wire and voltage-meter pickups work.
- [ ] Circuit puzzle rejects invalid configurations and powers the gate only on success.
- [ ] Radio broadcast and Continue transition work.
- [ ] Level 2 includes the hydraulic gate, timed rerouting, and both modules.
- [ ] Level 3 includes Stalker AI, monitor/keypad puzzle, calibration, and flare traps.
- [ ] Level 4 includes all three enemy types, four-sector coolant sequence, tri-key puzzle, and elevator.
- [ ] Level 5 includes transmitter assembly, controlled respawning pressure, turrets/traps, and all boss phases.
- [ ] Enemy AI, damage, death, checkpoint, and recovery work.
- [ ] Tactical Focus has a bounded duration/effect and reliable recovery.
- [ ] SOS, helicopter extraction, ending, credits, and return-to-menu work.
- [ ] Graphical run checks character, materials, lighting, shaders, UI, collision alignment, and performance.
- [ ] Final report separates designed, implemented, automated-tested, visually verified, and unverified items.

A design requirement is not proof of implementation. Update status only after the corresponding feature is present and verified.
