# Pointerworks — Art Spec

## Palette (6 colors — canonical, defined in `scripts/util/color_palette.gd`)

| Name | Hex | Role |
|---|---|---|
| `BG_DARK` | `#0E1320` | Background fill, canvas clear color |
| `FG_LIGHT` | `#F2F0E9` | Text, UI foreground, title word-mark |
| `EMITTER_AMBER` | `#E8A53A` | Emitters, deflectors, speed modifiers — "hot" industrial |
| `CURSOR_MAGENTA` | `#D946B3` | Virtual cursor trails, splitters, teleporters |
| `TARGET_CYAN` | `#3AD4D6` | Targets, success flashes, pressure-gauge aesthetic |
| `WALL_GREY` | `#4A5060` | Walls, bulkheads, HUD panels |

### Colorblind palette variant (toggled via Settings)

When `Settings.colorblind_palette` is true:
- `EMITTER_AMBER` → `#2E7AE8` (deuteranopia-safe blue)
- `CURSOR_MAGENTA` stays (already safe)
- `TARGET_CYAN` stays (already safe)

All Polygon2Ds subscribe to `Settings.settings_changed` and re-fetch colors.

## Part visual spec

See [../PARTS.md](../PARTS.md) for each part's shape, color, and size.

Every part:
- 64 × 64 px grid cell
- 4 px inset from edges (so parts don't visually collide)
- Polygon2D base + optional Line2D outline
- No PNG textures; no GPUParticles2D; no AnimationPlayer

## Virtual cursor

- 12 px arrow Polygon2D, `CURSOR_MAGENTA` fill.
- Line2D trail child: 8 points, gradient alpha 1.0 → 0.0 along length, ~60 px long.
- Death effects via Tween (red flash for walls, fade for off-grid, dissolve for TTL).

## Shaders (GL Compatibility, ≤2 canvas_item shaders total)

| Shader | Type | Purpose | Size |
|---|---|---|---|
| `shaders/grid_glow.gdshader` | canvas_item | Procedural grid glow on the background ColorRect | ~15 lines |
| `shaders/target_pulse.gdshader` | canvas_item | `sin(TIME)` alpha modulation on Target parts | ~10 lines |

## Animation catalog (Tween only — no AnimationPlayer)

| Element | Type | Duration | Easing |
|---|---|---|---|
| Part place pop-in | scale 0.0 → 1.1 → 1.0 | 0.18 s | EASE_OUT_BACK |
| Part remove shrink | scale → 0.0 + alpha fade | 0.12 s | EASE_IN |
| Target pulse | shader | continuous | sin(TIME) |
| Target hit flash | brightness → white → back | 0.15 s | EASE_OUT |
| Run button press | scale 1.0 → 0.95 → 1.0 | 0.1 s | EASE_IN_OUT |
| Win dialog fade-in | alpha 0 → 1 | 0.3 s | EASE_OUT |
| Level complete screen-shake | Camera2D offset ±8 px | 0.15 s | EASE_OUT |
| Main menu title idle | Y offset ±3 px loop | 2 s | sin-wave |
| Tutorial overlay slide-in | X offset -600 → 0 | 0.4 s | EASE_OUT |

## Cover image (itch.io)

- 630 × 500 PNG, ≤500 KB, `docs/cover.png`.
- Composition: center-left emitter → deflector → splitter → 2 targets with magenta trails on `BG_DARK` grid.
- Full spec in [PLAN.md § Cover image](./PLAN.md#itchio-cover-image--spec--requirements).

## In-engine screenshots (Day 7)

3 × 1280 × 720 PNGs to `docs/screenshots/`:
1. BUILD phase with palette visible
2. RUN phase with cursor trails mid-flight
3. WIN dialog with ⭐ par-cursors rating
