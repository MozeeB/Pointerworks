# Pointerworks — Claude Agent Context

## Source of Truth

**Read `docs/PLAN.md` FIRST before any work.** That file is the single source of truth:
scope, schedule, FSMs, tool choices, theme, risks, edge cases. This file (`CLAUDE.md`)
only summarizes + points to it. If they conflict, `docs/PLAN.md` wins.

## What this is

Gamedev.js Jam 2026 entry. Theme: Machines. HTML5 puzzle game built in Godot 4.6.
Core mechanic: the OS mouse cursor is the "working fluid" of grid-based machines.
Full theme rationale in `THEME.md`. Full game flow in `docs/GAME_FLOW.md`.

## Tech stack

- Godot 4.6, GL Compatibility renderer, 2D only (3D stripped).
- GDScript. No C# or GDExtension.
- Web export target (non-threads variant).
- Levels stored as `.tres` custom Resources, not JSON.

## Sprint

7-day sprint, Apr 16 → Apr 22 2026. See `DEVLOG.md` for current day status.

## Conventions

- Many small files: 200-400 lines typical, 800 hard cap.
- Feature-folder organization (scripts/parts/*, scripts/level/*, etc.).
- Immutable data patterns — return new copies, don't mutate.
- Signals for cross-node communication; autoloads only for truly global state.
- No AnimationPlayer nodes — Tween only.
- Colors come from `scripts/util/color_palette.gd` — no hex literals in game code.
- Checkboxes in `docs/PLAN.md`: `[ ]` pending, `[~]` in progress, `[x]` done.

## Response style

**Default: Caveman Ultra.** Chat replies only — fragments, drop articles, arrows for causality, abbrev OK (DB, req, res, TTL, MCP). Code / commits / PRs / `.md` edits / DEVLOG stay normal. Safety-critical or irreversible ops suspend caveman until clarity. Skill: `/Users/mujibnoctua/.claude/skills/caveman`. Switch via `/caveman [level]`.

## Verification — non-negotiable

Per `docs/PLAN.md` § "Verification Cadence":

- **Per task (after every `.gd` / `.tscn` write):** Godot MCP `run_project` → `get_debug_output`. Fast editor parse check.
- **Per commit + per EOD (Day 2 onward):** Claude Preview MCP on the web build. Since we ship HTML5, this is the authoritative test. Start with `preview_start` (config `pointerworks-web` in `.claude/launch.json`), then `preview_screenshot` + `preview_console_logs`. Save screenshot to `docs/preview-day-N.png`.
- **Checkbox rule:** no `- [ ]` item flips to `- [x]` until the relevant run is clean. If anything errors, stays `- [~]`.
- **Fallback if MCPs unavailable:** Godot headless CLI (`--check-only --path .`) for parse; real Chrome on `python3 -m http.server 8000` for web. Log `MCP unavailable — used fallback` in the DEVLOG `Verify:` bullet.
- **`Verify:` bullet is mandatory** in every Day N DEVLOG entry (format example in the plan's EOD checklist).

## DO NOT

- Add GPUParticles2D (GL Compatibility issues on web).
- Use threads-variant web export (COOP/COEP hosting pain).
- Pull in sprite asset packs (keeps bundle <15 MB).
- Add AnimationPlayer — use Tween.
- Ship Ethereum as *required* — it must be 100% skippable (offline players must still finish the game).
- Commit `.env` or private keys — `.env` is gitignored; deployer key is a throwaway.

## Directory map

```
scripts/autoload/  — SceneSwitcher, Progress, AudioBus, Settings, Web3Bridge
scripts/level/     — GridSystem, VirtualCursor, PhaseController, WinChecker, FailChecker, LevelLoader
scripts/parts/     — Part base + 7 part subclasses
scripts/ui/        — MainMenu, LevelSelect, HUD, PartPalette, WinDialog, PauseMenu, SettingsDialog, TutorialOverlay, DesktopOnlyBlocker
scripts/data/      — LevelResource, PartPlacement, PartData
scripts/web3/      — ethers_glue.js (custom JS for HTML5 shell)
scripts/util/      — color_palette, assert_dev
data/levels/       — l01.tres … l10.tres
contracts/         — PointerworksAchievements.sol, foundry.toml (Day 5)
shaders/           — grid_glow, target_pulse
audio/             — sfx/*.ogg, music/factory_loop.ogg
docs/              — PLAN.md, ART.md, GAME_FLOW.md, cover.png, trailer.gif, screenshots/
```

## Known dragons

- `get_global_mouse_position()` returns canvas coords, not window — safe.
- Browsers pause audio until first click; music starts on PlayButton press.
- `user://save.cfg` on web is backed by localStorage — 5 MB hard cap (fine for us).
- Web export must be the **non-threads** variant; threads require COOP/COEP and itch.io's SharedArrayBuffer toggle OFF.
- **Mobile is supported** (Day 9f): tap = place, long-press (≥0.45 s, no drag) = remove. Right-click still removes for mouse users. Viewport blocker only fires on portrait or <720×480; landscape orientation enforced via `window/handheld/orientation=4` (sensor_landscape).

## Current sprint day

Day 1 of 7 (Apr 16 2026) — 5 of 7 parts shipped (Emitter, Wall, Target, Deflector, Splitter) + `GridSystem` + `VirtualCursor` + `scenes/dev/part_test.tscn` smoke scene. See `DEVLOG.md` for end-of-day entries and `docs/PLAN.md` FAST-RESUME block for current live state.
