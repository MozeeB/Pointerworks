# Pointerworks DEVLOG

Daily journal for the 7-day jam sprint (Apr 16 → Apr 22, 2026). Two-to-five lines per day: what shipped, what was cut, next blocker.

---

## Day 5 — 2026-04-17

- **Ethereum challenge plumbing shipped (skippable by design).**
- Solidity contract: `contracts/src/PointerworksAchievements.sol`. `completeLevel(uint8 levelId, bytes32 hash)` with per-player bitmap + first-solution hash storage + `LevelCompleted` event. Idempotent replays; `InvalidLevel` revert for levelId ≥ 10. View helpers `hasCompleted` + `completedCount`.
- Forge tests: `contracts/test/PointerworksAchievements.t.sol` — 4 tests covering basic complete, idempotency, invalid revert, multi-level accumulate. Foundry project + Deploy.s.sol + `.env.example` ship for user deploy.
- JS glue: `scripts/web3/ethers_glue.js` — lazy-loads ethers v6 from jsdelivr CDN on first `connect()`. Exposes `window.pointerworks.{connect,disconnect,isConnected,getAddress,completeLevel}`. Gracefully errors if no wallet.
- `scripts/autoload/web3_bridge.gd` rewritten — replaces Day 1 stub with full JavaScriptBridge integration. Boots the glue via `FileAccess.open(GLUE_PATH).get_as_text()` + `JavaScriptBridge.eval()`. Polls `window.__pw_connect_result` / `__pw_tx_result` via timer; emits `wallet_connected`, `tx_pending`, `tx_confirmed`, `wallet_error` signals. `is_wallet_connected` / `get_address` / `complete_level` / `connect_wallet` / `disconnect_wallet` public API.
- Main menu gains `Connect Wallet (optional)` button (hidden on non-web). Short-address display once connected. HUD WinPanel gains `Submit on-chain` button that shows only when wallet connected; `Level._on_submit_on_chain` computes deterministic `sha256(levelId + placements)` hash, calls `Web3Bridge.complete_level(levelIndex, 0x…)`.
- Export preset `include_filter="*.js"` added so the glue ships inside the web PCK. Verified via `preview_eval`: `window.pointerworks` exposes the expected `object` on reload.
- Verify: headless parse clean (two GDScript multi-line grouping bugs fixed — GDScript does not auto-concat parenthesized string literals, needs explicit `+`). Re-exported web build; Claude Preview confirms Connect Wallet button renders on main menu. `typeof window.pointerworks === 'object'` + `window.POINTERWORKS_CONTRACT === 0x000…000` confirmed via preview_eval.
- Non-blocking TODO: bundle still 36 MB wasm raw (gzip at D7); contract not deployed (user self-serve per README). Local Progress still marks complete regardless of TX; gameplay unaffected.
- Next (Day 6): robustness (save corruption handling + LevelLoadErrorDialog) + playtest + levels 9-10 (Reactor + Cyclotron).

---

## Day 4 — 2026-04-17

- **Gap audit items #1-8 closed.** FailChecker (`scripts/level/fail_checker.gd`) polls `virtual_cursors` group during RUN; after grace ticks, if all cursors dead + any target unhit, emits `level_failed(missed_targets)`. Level auto-returns to BUILD after 2 s. HUD gains `FailBanner` (`Machine stalled — N targets unfed.`) with Tween fade.
- PauseMenu (`scenes/ui/pause_menu.tscn`) — Resume / Restart / Settings / Back-to-Menu, `process_mode = ALWAYS`, `get_tree().paused = true` while visible.
- SettingsDialog (`scenes/ui/settings_dialog.tscn`) — Master / Music / SFX HSliders, Fullscreen + Colorblind CheckButtons; wired through `Settings.set_*` typed setters so side-effects fire (AudioServer bus volume, DisplayServer mode, settings_changed signal).
- TutorialOverlay (`scenes/ui/tutorial_overlay.tscn`) — on-theme mechanic intro + shortcuts row + Got it button. MainMenu._ready spawns it when `Progress.seen_tutorial == false`. Dismiss persists the flag.
- DesktopOnlyBlocker (`scenes/ui/desktop_only_blocker.tscn`) — MainMenu pre-checks via `OS.has_feature("mobile"/"android"/"ios")` and `DisplayServer.is_touchscreen_available()`; blocker overrides the menu if true.
- InputMap actions (`project.godot`): `pw_pause` (Esc), `pw_run_toggle` (Space), `pw_rotate` (R), `pw_fullscreen` (F11). Level `_unhandled_input` routes them.
- Main Menu now has Credits button + jam tag + subtitle.
- Verify: Godot headless clean on main / level. Web re-exported. **Claude Preview first-run → TutorialOverlay opens with full mechanic blurb + shortcuts; Got it dismisses → Main Menu; second reload shows no tutorial (Progress persisted correctly). Zero console errors.**
- Next (Day 5): Ethereum challenge — Foundry + Solidity `PointerworksAchievements` on Sepolia + ethers.js v6 bridge via `JavaScriptBridge` + optional Connect Wallet button. Must remain 100% skippable.

---

## Day 3 — 2026-04-17

- Shipped AM: levels 5-8 as .gd builders — l05 Lathe (SpeedMod ×2), l06 Kiln (SpeedMod ×0.5 + Deflector), l07 Foundry (Teleporter pair), l08 Assembly (all 7 parts in one machine: emitter → speed → splitter → up-branch (deflector + teleporter across grid) + down-branch (deflector + slow) → two targets). `level_select` unlock cap raised to 8.
- Shipped mid: art polish. `shaders/grid_glow.gdshader` — canvas-item shader, procedural 64 px grid with soft glow, GL-Compatibility safe. `shaders/target_pulse.gdshader` — sin-modulated brightness for unhit targets; disabled on hit + re-enabled on reset. Tween juice: Part place pop-in (scale 0 → 1.1 → 1.0, 0.18 s EASE_OUT_BACK), Run button press squish, main-menu title idle float (±3 px sine loop).
- Shipped PM: Credits scene + SceneSwitcher.to_credits(). Main menu gains Credits button + jam subtitle. HUD win-dialog copy is per-level on-theme (Conveyor hums., Press seated. Clean shear., Full line — green across the board., etc.).
- Skipped PM: music gen (HF MCP not wired in-session; BeepBox manual trip deferred; AudioBus already no-ops on missing files). TODO Day 4 or 7.
- Verify: headless boot clean on main.tscn, level.tscn, credits.tscn (zero SCRIPT ERROR). Web re-export (~36 MB wasm raw). Claude Preview reloaded — `docs/preview-day-3` shows grid_glow rendering across the Conveyor floor + cyan target pulsing; Main menu now shows Credits + Play + subtitle. Zero console errors (`preview_console_logs level=error` → empty).
- Next (Day 4 morning): UX gap closure — FAIL state + FailChecker, Pause menu (Esc), Settings dialog with colorblind palette toggle, Tutorial overlay first-run, Desktop-only blocker, keyboard shortcuts + undo stack.

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
