# Theme — "Machines"

Gamedev.js Jam 2026 theme is **Machines**. Pointerworks answers the brief through **four simultaneous interpretations**, each reinforcing the others.

## Four layers of "Machines"

### 1. The factory is the machine (diegetic)

Every level is a literal machine the player assembles from parts on a grid: Emitter, Deflector, Splitter, Speed Modifier, Teleporter, Target. The machine has inputs (real cursor), processing stages (parts mutate velocity/direction/count), and outputs (Target tiles light up). Levels are named after industrial machinery: *Conveyor, Press, Forge, Refinery, Lathe, Kiln, Foundry, Assembly, Reactor, Cyclotron*. Each level's intro card calls out the machinery metaphor.

### 2. The player is the machine (meta)

In Pointerworks the mouse cursor is not a tool — it's *fuel*. The player's real cursor enters an Emitter and the machine consumes it, converting motion into virtual cursors that do work. This inverts the usual "you are the operator" trope; **you** are the raw material, the conveyor belt is everywhere else. Players feel this the first time they realize hovering an Emitter produces output.

### 3. The browser is the machine (platform)

The OS mouse cursor only exists on desktop browsers — this mechanic can't be ported. We lean into it: the title screen has a subtitle "Runs on your browser's cursor.", the tutorial explicitly says "Your real cursor is the fuel", and the desktop-only blocker says "Pointerworks runs on desktop mouse hardware." The platform IS the machine.

### 4. Debugging is gameplay (meta-meta)

Puzzle-solving here feels like repairing a broken machine: you watch virtual cursors flow, spot where they die (wall, off-grid, TTL), tweak a Deflector by 90°, run again. The BUILD → RUN → FAIL → BUILD loop is literally the industrial iterate-and-fix cycle. Par-cursors rating rewards *efficient* machines — the player becomes a mechanical engineer optimizing a factory line.

## How the theme shows up in each system

| System | How it expresses "Machines" |
|---|---|
| **Visual design** | Factory-floor aesthetic: amber emitters resemble furnace mouths, cyan targets resemble pressure gauges, walls are grey industrial bulkheads, cursor trails resemble sparks. Grid shader = glowing floor plates. |
| **Audio (music)** | MusicGen prompt: *"chiptune factory ambient loop, 110 BPM, minor key, industrial clanks"*. The rhythm itself evokes machinery. |
| **Audio (SFX)** | `spawn` = hydraulic hiss, `deflect` = metallic clank, `hit_target` = pressure-release valve, `win` = assembly line success chime, `place_part` = bolt-tightening click. |
| **Level names** | l01…l10 are 10 real industrial machines (Conveyor through Cyclotron). |
| **Level progression** | L1-3 teach a single machine component (like learning a lathe). L4-7 combine components. L8-10 are "factory floor" problems. |
| **Tutorial copy** | "Your real cursor is the fuel. Emitters refine it into virtual cursors. Deflectors redirect them. Targets are the machines you're powering. Build the factory. Run the factory. Fix the factory." |
| **Win-dialog copy** | Varies per level: "Machine calibrated." / "Factory line operational." / "Reactor critical — in a good way." |
| **Fail-banner copy** | "Machine stalled — X targets unfed." (not "you failed" — blame is on the machine, encouraging iteration). |
| **Ethereum integration** | "Submit on-chain" = the factory stamps a permanent certification into the blockchain ledger. |
| **itch page description** | Short description leads with "Build factories where your own mouse cursor is the raw material." |

## Theme-fit verification checklist (Day 7 pre-submit)

Before submitting, every item below must pass:

- [ ] Every level's `name` field is a machine from the list.
- [ ] Short description on itch page opens with a machine word.
- [ ] Cover art shows recognizable factory/industrial imagery.
- [ ] Tutorial uses the word "machine", "factory", or "fuel" at least 3 times.
- [ ] Credits page thanks "the machines that built this game" (meta joke).
- [ ] This `THEME.md` in repo root states all 4 interpretations for judges browsing source.
- [ ] Itch page tags include `machines` and `factory` alongside technical tags.

## Stand-in justification (paste verbatim into jam submission form)

> **Pointerworks is "Machines" four times over:**
>
> 1. **The factory is the machine** — every level is a literal machine you assemble from Emitters, Deflectors, Splitters, and Targets on a grid.
> 2. **The player is the machine's fuel** — your real mouse cursor is the raw material the factory consumes; no cursor movement = no output.
> 3. **The browser is the machine** — the mouse-cursor-as-fuel mechanic only works on a desktop browser, so the game uses the platform itself as a machine part.
> 4. **Debugging is gameplay** — the BUILD → RUN → FAIL → BUILD loop turns the player into a mechanical engineer iterating on a factory line.
>
> Built in 7 days with Godot 4.6; qualifies for Open Source (MIT, public GitHub) + Ethereum (Sepolia on-chain level completions).
