# Pointerworks — Parts Reference

The 7 parts that make up every machine. Each part is 64 × 64 px, placed on a grid cell, and interacts with virtual cursors that overlap it.

| Part | Mechanic | Inputs → Outputs | Visual spec | Sound |
|---|---|---|---|---|
| **Emitter** | Real cursor overlap spawns a virtual cursor flying in the emitter's facing direction. | real mouse → 1 virtual cursor/frame (throttled) | Amber (`#E8A53A`) furnace mouth with directional chevron. | `spawn.ogg` — short digital pop. |
| **Wall** | Virtual cursors die on contact (red flash + fade). | virtual cursor → nothing | Grey (`#4A5060`) rounded square, subtle border. | (shared death SFX) |
| **Target** | Virtual cursor contact marks the target as hit. Emits `target_hit`. | virtual cursor → hit state | Cyan (`#3AD4D6`) circle with pulse shader. | `hit_target.ogg` — pressure-release chime. |
| **Deflector** | Rotates cursor velocity 90° per rotation step. Cursor passes through. | virtual cursor (dir N) → virtual cursor (dir E/W) | Amber chevron with rotation arrow. | `deflect.ogg` — metallic clank. |
| **Splitter** | Consumes input cursor; spawns 2 children at perpendicular angles. | 1 virtual cursor → 2 virtual cursors | Magenta (`#D946B3`) Y-shape. | `deflect.ogg` (reused) |
| **Speed Modifier** | Scales cursor velocity ×0.5 or ×2.0 on pass-through. | virtual cursor v → virtual cursor v × factor | Amber arrow stack (up = faster, down = slower). | `deflect.ogg` (reused) |
| **Teleporter** | Paired tiles; entering cursor despawns, new cursor spawns at paired tile with same velocity. | virtual cursor @ A → virtual cursor @ B | Magenta ring with inner swirl. | `deflect.ogg` (reused) |

## Rules

- **Rotation:** Only Deflector, Emitter, Speed Modifier, and Teleporter have rotation variants. Wall and Target are symmetric.
- **Collision order:** If a cursor overlaps multiple parts in the same frame, z-index ordering resolves — higher z wins.
- **Wall:** Cursor on Wall = die with red flash + fade (0.2 s). Documented in `scripts/level/virtual_cursor.gd`.
- **Off-grid:** Cursor leaving grid rect = die with fade (0.15 s).
- **TTL:** Every cursor has a 5 s time-to-live; expires with a dissolve (0.3 s).
- **Splitter fork bomb:** Max 64 live cursors. Oldest dies first.
- **Multiple Emitters:** Allowed per level. Each emits independently.
- **Teleporter pairing:** LevelResource validates pairs at load time. Unpaired teleporter → LevelLoadErrorDialog.

## Part-by-part implementation status

| Part | Status | File |
|---|---|---|
| Emitter | Day 1 — script + scene ✓ | `scripts/parts/emitter.gd`, `scenes/parts/emitter.tscn` |
| Wall | Day 1 — script + scene ✓ | `scripts/parts/wall.gd`, `scenes/parts/wall.tscn` |
| Target | Day 1 — script + scene ✓ | `scripts/parts/target.gd`, `scenes/parts/target.tscn` |
| Deflector | Day 1 — script + scene ✓ | `scripts/parts/deflector.gd`, `scenes/parts/deflector.tscn` |
| Splitter | Day 1 — script + scene ✓ | `scripts/parts/splitter.gd`, `scenes/parts/splitter.tscn` |
| Speed Modifier | Day 2 AM — script + scene ✓ | `scripts/parts/speed_mod.gd`, `scenes/parts/speed_mod.tscn` |
| Teleporter | Day 2 AM — script + scene ✓ | `scripts/parts/teleporter.gd`, `scenes/parts/teleporter.tscn` |

Updated as each part lands during Days 1-2.

## Day 1 smoke scene

`scenes/dev/part_test.tscn` exercises all 7 parts:

- **Row 1 (y=160):** EmitterA → straight-line → TargetA. WallA below path is inert until crossed.
- **Row 2 (y=416):** EmitterB → Splitter forks UP and DOWN → DeflectorUp (steps=0) turns UP→RIGHT → TargetUp; DeflectorDown (steps=2 / node rot=π) turns DOWN→RIGHT → TargetDown.
- **Row 3 (y=640):** EmitterC → SpeedFast (×2 velocity) → TeleporterA (pair_id=1) → TeleporterB (pair_id=1) → TargetC.

Hovering each emitter with the real OS cursor should light up every target. Fork-bomb guard (`Splitter.MAX_LIVE_CURSORS=64`) + 36 px spawn offset on both Splitter and Teleporter prevents runaway cursor counts + ping-pong re-entry.

## Parse + boot verification (Day 2 AM)

Godot MCP unavailable this session → plan's CLI fallback used:

```
Godot --headless --quit-after 3 --path . res://scenes/dev/part_test.tscn
```

Output: clean boot, only UID warnings (synthetic UIDs fall back to file paths; harmless). Zero SCRIPT ERROR / Parse error. Interactive smoke (real mouse hover) awaits Day 2 EOD web export + Claude Preview.
