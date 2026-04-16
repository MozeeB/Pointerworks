# Pointerworks — Level Design Notes

10 levels, each named after an industrial machine (theme reinforcement). Grid size 16 × 9 tiles (64 px each → 1024 × 576 canvas inset in 1280 × 720 viewport).

| Lvl | Name | Concept taught | Parts introduced | Par cursors | Notes |
|---|---|---|---|---|---|
| l01 | Conveyor | Emitter → Target in straight line | Emitter, Target, Wall | 1 | Single emitter, single target, no obstacles. Tutorial tooltip fires here. |
| l02 | Press | 90° routing | Deflector | 1 | Single L-bend. Introduces rotation shortcut (R key). |
| l03 | Forge | Two targets in sequence | Multiple targets | 2 | Routing through a corridor hitting 2 targets. |
| l04 | Refinery | Split one stream into two | Splitter | 1 (emits 2 via splitter) | Splitter fork to 2 targets. |
| l05 | Lathe | Acceleration for long runs | Speed Modifier (×2) | 1 | Long route that can't complete before TTL without ×2. |
| l06 | Kiln | Slow a cursor down for tight routing | Speed Modifier (×0.5) | 1 | ×0.5 required to navigate a tight deflector sequence. |
| l07 | Foundry | Jump across obstacles | Teleporter pair | 1 | Wall field splits the grid; teleporter required to reach target. |
| l08 | Assembly | Full combo: split + teleport + deflect | All 7 parts used | 2 | Mid-difficulty combination level. |
| l09 | Reactor | Optimize — "beat par" with 4 targets, tight budget | All parts; emphasize `par_cursors` | 3 | 4 targets, budgeted part count. Rewards efficient design. |
| l10 | Cyclotron | Multi-emitter, multi-teleporter maze | 2 emitters, 3 teleporters, 4 targets | 4 | Closing challenge. Designed for 5+ min solve. |

## Level design protocol

Every level follows this authoring checklist:

1. Sketch on paper (3 min).
2. Playtest intended path in editor (5 min).
3. Check for cheese paths (shortcuts not intended) — either patch with walls or allow as "bonus solve."
4. Measure `actual_cursors_used` with optimal build; set `par_cursors` = that number.
5. Write `hint` string (1 sentence; shown on first-load of the level via tooltip).
6. Verify deterministic-sim hash (logged at RUN start) — same grid + seed must produce same hash across runs.

## Cheese-path log

Levels may have unintended solutions discovered during playtesting. Not all cheese paths are bugs; some are fine as "you figured out a clever alternative." Log here for awareness.

| Lvl | Cheese | Intent | Fix or allow? |
|---|---|---|---|
| (none yet) | | | |

## Unlock rules

- l01 unlocked on first launch.
- l02…l10 unlock when the previous level's `Progress.is_completed()` returns true.
- After l10 complete: Credits screen accessible from MainMenu; "You've cleared all 10!" badge shown on next launch.
