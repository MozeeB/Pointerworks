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
| Emitter | — | `scripts/parts/emitter.gd` |
| Wall | — | `scripts/parts/wall.gd` |
| Target | — | `scripts/parts/target.gd` |
| Deflector | — | `scripts/parts/deflector.gd` |
| Splitter | — | `scripts/parts/splitter.gd` |
| Speed Modifier | — | `scripts/parts/speed_mod.gd` |
| Teleporter | — | `scripts/parts/teleporter.gd` |

Updated as each part lands during Days 1-2.
