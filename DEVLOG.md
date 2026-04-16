# Pointerworks DEVLOG

Daily journal for the 7-day jam sprint (Apr 16 → Apr 22, 2026). Two-to-five lines per day: what shipped, what was cut, next blocker.

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
