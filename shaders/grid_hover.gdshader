shader_type canvas_item;
// grid_hover — outlines the cell currently under the OS mouse cursor.
//
// Driven by GridSystem._process during BUILD phase only:
//   - hover_cell: integer grid coords (x, y); set to (-1, -1) to disable.
//   - tile_size: must match GridSystem.TILE_SIZE.
// Renders on top of grid_glow — wire as a second canvas-item shader on
// the level Background ColorRect via a simple sub-shader composite, OR
// (simpler) attach this shader to a dedicated overlay ColorRect added
// above the grid Background.
//
// GL Compatibility safe — no derivatives, no textureLod.

uniform vec2 hover_cell = vec2(-1.0, -1.0);
uniform float tile_size : hint_range(8.0, 256.0) = 64.0;
uniform vec4 ring_color : source_color = vec4(0.91, 0.65, 0.23, 1.0);
uniform float ring_thickness : hint_range(0.5, 6.0) = 2.0;
uniform vec2 grid_origin = vec2(128.0, 56.0);  // matches Level Grid node global pos
// canvas_size must match the logical viewport (default 1280×720).
// Using UV * canvas_size instead of FRAGCOORD avoids HiDPI scale mismatches.
uniform vec2 canvas_size = vec2(1280.0, 720.0);

void fragment() {
	if (hover_cell.x < 0.0) {
		COLOR = vec4(0.0);
		discard;
	}
	vec2 cell_min = grid_origin + hover_cell * tile_size;
	vec2 cell_max = cell_min + vec2(tile_size);
	// UV gives 0-1 over the ColorRect's logical extent; multiply by canvas_size
	// to get logical pixel coordinates, which match the grid's logical space.
	vec2 pix = UV * canvas_size;

	// Outside cell rect → fully transparent.
	if (pix.x < cell_min.x || pix.x > cell_max.x || pix.y < cell_min.y || pix.y > cell_max.y) {
		COLOR = vec4(0.0);
		discard;
	}

	// Distance to the nearest edge of the cell.
	float dx = min(pix.x - cell_min.x, cell_max.x - pix.x);
	float dy = min(pix.y - cell_min.y, cell_max.y - pix.y);
	float d = min(dx, dy);

	// Hard ring inside thickness band, soft falloff for 4 px past it.
	float ring = 1.0 - smoothstep(ring_thickness, ring_thickness + 4.0, d);
	COLOR = vec4(ring_color.rgb, ring_color.a * ring * 0.7);
}
