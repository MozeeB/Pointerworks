# Pointerworks DEVLOG

Daily journal for the 7-day jam sprint (Apr 16 → Apr 22, 2026). Two-to-five lines per day: what shipped, what was cut, next blocker.

---

## Day 2 — 2026-04-17

- Shipped Day 2 AM: `SpeedMod` (factor-based velocity scaling, META_KEY double-apply guard, MIN/MAX speed clamp) + `Teleporter` (pair_id matching via group scan, 36 px spawn offset prevents ping-pong). Extended `scenes/dev/part_test.tscn` with Row 3: EmitterC → SpeedFast → TeleporterA/B → TargetC. Commit `1b1011a`.
- Shipped Day 2 midday: custom Resource types (`LevelResource`, `PartPlacement`), runtime systems (`PhaseController` FSM BUILD/RUN/WIN/FAIL, `WinChecker`, `LevelLoader` with validate+populate, `Level` composite root), UI (`HUD` scene + script with title/phase/back/run/stop + `WinPanel` with ⭐ par rating, `LevelSelect` 5-col grid with ⭐/🔒 badges). Levels `l01 Conveyor`, `l02 Press`, `l03 Forge`, `l04 Refinery` as `.gd` builders (jam-friendly authoring — plan adjusted to support both `.gd` and `.tres`). `Progress` API converted to String keys. `SceneSwitcher.pending_level_id` stash + `next_level_id`. Target no longer consumes cursor (cursors pass through). Commit `e7cc5d3`.
- Day 2 EOD: **First Web export built.** Installed Godot 4.6.1 templates (web_nothreads_debug/release). `build/index.{html,wasm,pck,js}` produced (~36 MB wasm uncompressed; gzip ship size ~9-12 MB — TODO check at Day 7 vs. 15 MB budget). `default_bus_layout.tres` (Master/Music/SFX buses) registered in `project.godot`. `.claude/launch.json` wired to `/Users/mujibnoctua/.local/node/bin/http-server` (system python3 was sandboxed; installed `http-server` via npm global).
- Verify: **Claude Preview smoke passed.** `preview_start pointerworks-web` boots build on port 8000. Scripted click-path Main Menu → Select a Machine → L01 Conveyor → Run via synthetic MouseEvent dispatch on canvas at game-coords. Phase transitioned BUILD → RUN; HUD updated (`RUN` label, `Stop` button). `preview_console_logs level=error` → 0 errors, only benign Godot engine/OpenGL init logs. Three commits pushed. **Note:** interactive cursor-spawn-on-hover requires real OS-mouse position sync; synthetic `mousemove` fires on canvas but Godot's Area2D `mouse_entered` derives from real pointer coordinates in web exports. Real browser hover verified via inline screenshots only — interactive assertion scripting deferred to manual Chrome session.
- Next (Day 3 morning): levels 5-8 + art polish (grid shader, target pulse shader, tween catalog) + music generation (HF MusicGen-small or BeepBox fallback) + main menu Figma polish.

---

## Day 1 — 2026-04-16

- Plan written (`docs/PLAN.md` v8) — 7-day sprint, Ethereum re-included, gap audit (20 items), theme (4 layers), itch.io submission form reference (40 fields), context-limit safety protocol.
- Bootstrapped: `project.godot` cleaned (3D stripped, 5 autoloads + 1280×720 display + GL Compatibility), full folder tree, 11 markdown docs, MIT LICENSE, `.gitignore`. Git init + first push to `MozeeB/Pointerworks` on `main` (commit `5fdedb7`).
- Core mechanic built: `GridSystem` (64 px tiles, place/remove/clear API), `VirtualCursor` (Area2D + velocity + TTL + world-space Line2D trail + 4 death causes), `Part` base class (Area2D overlap dispatch), + 5 parts (Emitter with 0.15 s spawn cooldown, Wall / Target / Deflector / Splitter with fork-bomb guard).
- 2-row smoke scene `scenes/dev/part_test.tscn` exercises straight-shot + split-and-deflect chains.
- Verify: Godot MCP unavailable; used headless CLI fallback per plan. Headless boot surfaced 3 latent bugs fixed in-session:
  1. `Web3Bridge.is_connected()` clashed with `Object.is_connected(signal, callable)` → renamed to `is_wallet_connected()`.
  2. `ColorPalette` class_name clashed with Godot 4 built-in `ColorPalette` resource (ColorPicker presets) → renamed to `AppPalette`; all call sites updated.
  3. Enum `Name` was a reserved-ish identifier causing parse errors → renamed to `Swatch`.
- After fixes: `Godot --headless --quit-after 3` clean on both `scenes/main.tscn` and `scenes/dev/part_test.tscn`. Zero SCRIPT ERROR / ERROR output.
- Interactive smoke (hover emitter → targets lit, splitter fork, wall kill) deferred to Day 2 EOD when web build + Claude Preview harness comes online.
- Next (Day 2 morning): Speed Modifier + Teleporter → phase FSM + palette drag-drop + 4 levels → first web export + Preview harness (`.claude/launch.json`, `preview_screenshot` to `docs/preview-day-2.png`).
