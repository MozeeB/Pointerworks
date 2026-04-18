# Pointerworks DEVLOG

Daily journal for the 7-day jam sprint (Apr 16 → Apr 22, 2026). Two-to-five lines per day: what shipped, what was cut, next blocker.

---

## Day 9 — UI/UX polish pass — 2026-04-18

User said "feels too easy / rough". Audit identified discoverability + feedback + hierarchy gaps. Closed in 6 phases over one session.

- **D12 — AppPalette swatches.** `Swatch` enum extended: `FAIL_RED`, `WIN_GREEN`, `HOVER_TINT`, `SELECTION_RING`, `OVERLAY_DIM`, `MUTED_TEXT`, `ACCENT`. `get_color()` branches on each, with colorblind swap on amber/selection_ring. HUD FailBanner color migrated to match `FAIL_RED`.
- **Phase A — Affordance.**
  - A1 `shaders/grid_hover.gdshader` (canvas_item, GL Compatibility safe). New `HoverOverlay` ColorRect in `level.tscn` with the shader. `GridSystem._process` polls `get_global_mouse_position()` → cell coords → sets `hover_cell` uniform. Active only in BUILD; cleared on RUN/WIN/FAIL.
  - A2 Emitter idle pulse — looping Tween (modulate.a 1.0↔0.85 + scale 1.0↔1.06 over 1.2 s, sine ease). Subscribes to PhaseController.phase_changed, pauses on RUN.
  - A3 Palette fade-in on BUILD entry — Level._animate_palette_visibility tweens `modulate.a` 0→1 + `position.y` +16→origin over 0.25 s (TRANS_QUART). Mirror fade-out on phase exit.
  - A4 Palette hint chip row — `PaletteHintRow` Label below palette: "1-7 select · click cell to place · R rotate · right-click remove · Z undo". Fades in 0.4 s after palette with 0.15 s delay.
- **Phase C — Feedback.**
  - C1 `Level._flash_cell(cell)` — TILE_SIZE Polygon2D ACCENT square, scale 1.0→1.25 + alpha 0.8→0 over 0.3 s. Fires on placement (palette + undo-restore paths).
  - C2 `Target._celebrate_burst()` — 8 small triangles radiate outward 28 px + fade 0.5 s, WIN_GREEN tint. Pure Polygon2D (no GPUParticles2D) for GL Compatibility safety.
  - C3 `Emitter._birth_flash()` — magenta 12-sided ring scales ×5 + fades 0.25 s on every cursor spawn. Player traces emit cadence visually.
  - C4 `Level._play_fail_red_breathe()` — 0.6 s red modulate dwell on Level Node2D alongside existing screen shake. Doesn't block input.
- **Phase B — Hierarchy.**
  - B5 `WinDimOverlay` ColorRect added to HUD (full-rect black @ 55 % alpha). HUD.show_win fades dim in alongside WinPanel; hidden on retry / phase BUILD.
  - B6 HintBanner moved from y=72 (overlapping TopBar title) to y=540 (above palette / mid-bottom). Font size 16→17.
  - B7 PhaseLabel font 20→14, color → `MUTED_TEXT` so the level title dominates.
- **Phase D — Palette polish.**
  - D13 Selection ring — `_animate_slot_selection` tween scale 1.0→1.08 + modulate ×1.15 brightness on selected slot, reverse on deselect (0.12 s).
  - D14 Number badges — each slot gets a top-right "1"…"7" Label (font 10, MUTED_TEXT) reinforcing `pw_part_N` shortcuts.
- **Phase E — Responsive blocker.**
  - DesktopOnlyBlocker gains `MIN_WIDTH=1100` / `MIN_HEIGHT=620` thresholds + `should_block()` static. `_ready` connects `get_tree().root.size_changed` and toggles visibility live on resize. MainMenu uses `should_block()` (was `is_mobile_device()` only).
- Verify: Godot headless boot clean on main + level (0 SCRIPT ERROR / 0 Parse). Web re-exported — PCK 866 KB → 876 KB (+10 KB for new chip row + WinDim overlay), wasm unchanged at 36 MB raw / ~9.4 MB gzip. Claude Preview reload clean; main menu renders all 3 buttons + jam tag. Live resize test deferred (browser blocked window.resizeTo).
- Bundle still well under 15 MB budget. No new asset files; only shader + Tween + Polygon2D.

---

## Day 8 (post-v1.0 gap closure) — 2026-04-17

User asked to close every code-gap. Done in one pass; all shipped.

- **Audio shipped.** `tools/gen_sfx.py` (Python stdlib `wave`, no ffmpeg needed) generates 5 tiny SFX + a 20 s factory-drone music loop directly into `audio/`. Files: `spawn.wav` 10 KB, `deflect.wav` 9 KB, `hit_target.wav` 18 KB, `win.wav` 58 KB, `place_part.wav` 7 KB, `music/factory_loop.wav` 1.7 MB. `AudioBus._get_sfx` now tries `.wav` first, falls back to `.ogg` (HF-gen swap-in path preserved). `prime_music` added WAV loop-mode branch. Hook points wired: Part _ready plays `place_part`; Level._on_level_complete plays `win`; Emitter keeps `spawn`; Deflector/Splitter/SpeedMod keep `deflect`; Target keeps `hit_target`.
- **PartPalette drag-replacement shipped.** `scripts/ui/part_palette.gd` — 7-slot click-to-select Control (not drag; jam-friendly). Per-slot count badge (−1 = ∞). `configure(types, counts)` called by Level from `LevelResource.palette_types` + `palette_counts`. `consume`, `restore`, `selected`, `select_slot_by_index` API. HUD owns the node at bottom; Level toggles visibility on BUILD entry + palette-nonempty.
- **Level place / remove / rotate wired.** `_try_place_at_mouse`, `_try_remove_at_mouse`, `_rotate_hovered_part`. Left-click = place (BUILD only); right-click = remove (BUILD + non-locked only); `R` rotates hovered part. Pre-laid placements with `locked=true` are immutable; Level tracks `_locked_cells`.
- **Undo stack (10-entry ring) shipped.** `_push_undo` / `_pop_undo` handle both `place` and `remove` ops. `pw_undo` → Z key (not Ctrl+Z for jam speed). Palette counts restored/consumed on undo. Cleared implicitly when level resets (since nodes re-built).
- **InputMap extended.** `pw_undo` (Z), `pw_part_1..7` (keycodes 49-55). Level `_unhandled_input` handles all plus grid clicks.
- **l04 Refinery now palette-mode.** Pre-laid emitter + 2 targets; palette exposes 1 splitter + 2 deflectors (exact count — no over-allocation). Player must place to solve. Demonstrates full feature.
- **Hint banner shipped.** Replaces "5 tooltip Labels for L1-3" plan item with a general-purpose per-level hint banner. `HUD.show_hint(text, dur)` fades in 0.4 s → holds duration → fades out 0.6 s. Every `LevelResource.hint` shown on BUILD entry.
- **Screen shake on fail shipped.** 6-kick position Tween on the Level Node2D (~0.3 s, ±6 px). Fires alongside `_on_level_failed`.
- **Remove shrink Tween shipped.** `Part.play_remove_shrink()` returns the Tween so callers can chain queue_free. Used by `_try_remove_at_mouse` + `_pop_undo`.
- **Colorblind live-swap shipped.** Emitter + SpeedMod subscribe to `Settings.settings_changed`, call `_apply_palette` which re-reads `AppPalette.get_color(EMITTER_AMBER)` (already returns the blue variant when `colorblind_palette` is true). No scene reload required. Wall/Target/Deflector/Splitter/Teleporter unchanged (non-amber).
- **Save-reset toast shipped.** HUD listens on `Progress.save_reset(reason)` + reuses `show_hint` to surface "Save reset — <reason>" for 3 s. Fires on version-mismatch + on read errors other than 404.
- Verify: headless main+level boot clean (0 SCRIPT ERROR). Re-exported web — PCK grew 478 KB → 866 KB (added audio files), wasm unchanged. Claude Preview (new server) boots clean; TutorialOverlay fires on fresh localStorage; 0 console errors.
- Still human-assist only: contract deploy, cover.png, 3 screenshots, trailer GIF/MP4, itch upload + jam submit. See `docs/SUBMISSION_CHECKLIST.md`.

---

## Day 7 — 2026-04-17

- **Submission prep. v1.0 tagged.**
- Bundle gzip sanity: `build/index.wasm` 36 MB raw → **9.4 MB gzip**; total over-the-wire **~9.7 MB** (budget was <15 MB). itch.io gzips static assets automatically. Measurement logged in `docs/SUBMISSION_CHECKLIST.md`.
- `docs/SUBMISSION_CHECKLIST.md` — Day 7 worksheet pointing at `docs/PLAN.md` § "itch.io submission form — field-by-field reference" (40-row table). Pre-submit gate checklist, upload-order sequence, field values, media-still-needed list.
- README polished: Theme-for-judges section (4 layers), shortcut row, controls clarification (parts pre-laid in v1.0; palette drag-drop deferred post-jam), link to SUBMISSION_CHECKLIST.md.
- Git tag `v1.0` created at Day 7 HEAD (detached on the EOD commit).
- Remaining human-assist items (Claude Preview MCP cannot persist canvas bitmaps to disk inline): `docs/cover.png` (630×500 PNG), 3 in-engine screenshots, GIF/MP4 trailer, itch.io account actions. All steps enumerated in the checklist.
- Final state: 10 levels live, 7 parts implemented, grid_glow + target_pulse shaders, Tween juice everywhere, full FSM (BUILD/RUN/WIN/FAIL), Pause + Settings + Tutorial + DesktopBlocker + LevelLoadErrorDialog, MIT licensed, Ethereum plumbing ready (deploy self-serve per README), non-threads web export 9.7 MB over wire.

---

## Day 6 — 2026-04-17

- **Robustness + levels 9-10 shipped.**
- LevelLoadErrorDialog (`scenes/ui/level_load_error_dialog.tscn`) — red title + reason text + Back-to-menu button. `Level._show_load_error()` replaces silent `push_error` on `level_resource == null` or validation failure.
- `Progress.save_reset(reason: String)` signal emits on non-ERR_FILE_NOT_FOUND load errors and on version mismatch, so HUD can surface a toast later (stub only; Day 7 polish).
- l09 Reactor — 1 emitter + splitter + 2 deflectors + speed mod + 2 teleporter pairs + 4 targets. Par 1 — one cursor fires both branches and both teleport pairs.
- l10 Cyclotron — 2 emitters, 2 teleporter pairs, 4 pass-through targets. Par 2 (one cursor per emit). Both loops independent; designed to look busy when both emitters are hovered.
- level_select.FIRST_AVAILABLE bumped 8 → 10. All 10 levels unlock via Progress.is_unlocked sequential gating.
- Verify: Godot headless clean after fixing `static func _show_load_error` slip (was static, should be instance). Re-exported web; Claude Preview main menu loads clean; `typeof window.pointerworks === 'object'` still holds; 0 fresh console errors.
- Deferred: real external playtest + interactive L9/L10 run-through (requires real OS-mouse hover; synthetic events don't trigger Godot Area2D mouse_entered). Day 7 manual-chrome smoke + external testers.
- Next (Day 7): web export gzip verify (must stay <15 MB), cover image 630×500, 3 screenshots, GIF/MP4 trailer, itch.io page fill + submission.

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
