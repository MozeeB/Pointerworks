# Pointerworks — Game Flow

Full state machines and sequence diagrams. Canonical copy of the "Detailed game flow" section of [PLAN.md](./PLAN.md). When updating, edit PLAN.md first, then propagate here.

## A. App lifecycle FSM (top-level)

```
┌─────────────┐
│   LAUNCH    │  _ready on Main scene
└──────┬──────┘
       ▼
┌─────────────────────┐  if OS.has_feature("mobile") or touchscreen_available
│ DESKTOP_CHECK       │───────────────┐
└──────┬──────────────┘               ▼
       │ (desktop)        ┌────────────────────┐
       ▼                  │ DESKTOP_ONLY       │ (terminal — no other transitions)
┌─────────────────────┐   │ BLOCKER            │
│ LOAD_SAVE           │   └────────────────────┘
│ (Progress.load,     │
│  Settings.load)     │
│  reset on corrupt   │
└──────┬──────────────┘
       ▼
┌─────────────────────┐
│ TUTORIAL_CHECK      │
└──────┬──────────────┘
       │ if not Progress.seen_tutorial
       ├──────► TUTORIAL_OVERLAY ──► (user dismisses) ──► MAIN_MENU
       │
       ▼ (seen already)
┌─────────────────────┐
│ MAIN_MENU           │──► Play ──► LEVEL_SELECT ──► pick ──► IN_LEVEL
│                     │──► Settings ──► SETTINGS_DIALOG ──► back
│                     │──► Credits ──► CREDITS ──► back
│                     │──► Connect Wallet (optional)
└─────────────────────┘
```

**Invariants:** `seen_tutorial` sticky; mobile blocker is terminal; LOAD_SAVE failure never crashes (resets + toast).

## B. In-level FSM (the core loop)

```
LEVEL_LOAD → BUILD ↔ PAUSE_MENU
         BUILD → (Space) → RUN ↔ PAUSE_MENU
         RUN → WinChecker targets hit → WIN
         RUN → FailChecker all cursors dead, target unhit → FAIL_BANNER → BUILD
         WIN → Next / Retry / Menu / Submit on-chain
```

**Invariants:**
- BUILD ↔ RUN reversible (Space both ways).
- RUN→BUILD wipes live cursors.
- WIN terminal per-level.
- FAIL auto-returns to BUILD after 2 s; grid NOT cleared.
- Pause works in BUILD and RUN; settings changes propagate live.

## C. Virtual cursor lifecycle

```
spawned by Emitter on real-mouse-enter
         ▼
    TRAVEL (Area2D, velocity, TTL = 5 s, Line2D trail)
         │
         ├─ overlaps modifier Part → Part.apply_to_cursor(self)
         ├─ overlaps Wall → DEATH (red flash, 0.2 s)
         ├─ off-grid → DEATH (fade, 0.15 s)
         ├─ TTL expires → DEATH (dissolve, 0.3 s)
         └─ hits Target → Target.mark_hit() → DEATH (gentle fade)
```

**Edge cases:**
- Two cursors hit same Target same frame → first counts; both die.
- Splitter consumes input, spawns 2 children with fresh TTL + perpendicular velocity.
- Teleporter pair: velocity preserved (not reflected).
- Max 64 live cursors — oldest dies first.
- Pause freezes `_physics_process` via `get_tree().paused = true`.

## D. Input precedence (Esc shouldn't open two dialogs)

```
TUTORIAL_OVERLAY > DESKTOP_BLOCKER > SETTINGS_DIALOG > PAUSE_MENU > IN_LEVEL
```

Each modal uses `_input` + `accept_event()` to stop propagation; the level uses `_unhandled_input`.

## E. Save/load flow

```
STARTUP:
  Settings.load()  → ok: apply volumes, fullscreen; fail: defaults + toast
  Progress.load()  → ok: unlock bitmap;           fail: defaults + toast

SETTINGS change: Settings.save() (debounced 500 ms)
LEVEL WIN: Progress.mark_completed(id, cursors) → Progress.save() (sync) → optional Web3Bridge.complete_level(id, hash)
TUTORIAL dismissed: Progress.seen_tutorial = true; save.
```

**Web localStorage notes:**
- Godot key: `userdata/_Pointerworks/save.cfg`.
- 5 MB hard limit; our payload <1 KB.
- "Clear site data" wipes → surface as toast, not crash.

## F. Ethereum TX flow (skippable)

```
MainMenu "Connect Wallet" → Web3Bridge.connect() → JS bridge → MetaMask
  ├─ no MetaMask → "Install MetaMask" link; no-op
  ├─ user rejects → toast; no-op
  └─ success → wallet_connected(address) signal; UI shows 0x123...abc

WIN dialog for level_id:
  if Web3Bridge.is_connected(): show "Submit on-chain"
  else: show "Connect wallet to record on-chain (optional)"

Submit clicked → Web3Bridge.complete_level(id, hash)
  ├─ tx_pending → spinner
  ├─ tx_confirmed → Etherscan link
  └─ wallet_error → toast; level STILL locally-completed
```

**Invariants:** failing TX never rolls back `Progress.mark_completed`; no TX required to unlock any level; wallet disconnect fires signal, UI drops to disconnected state.

## G. Edge cases & bug-prevention checklist

See [../PLAN.md § Edge cases](./PLAN.md#g-edge-cases--bug-prevention-checklist-to-test-before-day-7-submit) for the full 16-row table. Verify all before Day 7 submit.
