shader_type canvas_item;
// grid_glow — subtle glowing grid for the level floor.
//
// No textures. Canvas-item shader; GL Compatibility safe.
// Renders: dark navy base + 64-px grid lines with soft glow.

uniform vec4 bg_color : source_color = vec4(0.0549, 0.0745, 0.1255, 1.0);
uniform vec4 line_color : source_color = vec4(0.35, 0.42, 0.55, 1.0);
uniform vec4 dot_color : source_color = vec4(0.91, 0.65, 0.23, 1.0);
uniform float tile_size : hint_range(8.0, 256.0) = 64.0;
uniform float line_thickness : hint_range(0.5, 6.0) = 1.2;
uniform float glow_strength : hint_range(0.0, 1.0) = 0.25;
uniform float dot_radius : hint_range(0.0, 6.0) = 1.6;

void fragment() {
	// Work in pixel-space derived from FRAGCOORD so the grid aligns with
	// the game's grid regardless of Control size.
	vec2 pix = FRAGCOORD.xy;
	vec2 grid = mod(pix, tile_size);

	// Distance (in px) to the nearest grid line in each axis.
	float dx = min(grid.x, tile_size - grid.x);
	float dy = min(grid.y, tile_size - grid.y);
	float d = min(dx, dy);

	// Hard line in the thickness band, soft glow outside.
	float line = 1.0 - smoothstep(0.0, line_thickness, d);
	float glow = 1.0 - smoothstep(line_thickness, line_thickness + 6.0, d);
	glow *= glow_strength;

	// Intersection dots — subtle amber pip at every grid corner.
	// Distance to nearest intersection = sqrt(dx² + dy²).
	float di = sqrt(dx * dx + dy * dy);
	float dot_mask = 1.0 - smoothstep(dot_radius, dot_radius + 1.2, di);

	vec3 color = mix(bg_color.rgb, line_color.rgb, max(line, glow));
	color = mix(color, dot_color.rgb, dot_mask * 0.85);

	// Honour the ColorRect's incoming COLOR.a so a SubViewport behind the
	// grid can peek through. Lines + glow + dots stay fully opaque so they read.
	float bg_alpha = COLOR.a;
	float fg_alpha = max(max(line, glow), dot_mask);
	float final_alpha = max(bg_alpha, fg_alpha);
	COLOR = vec4(color, final_alpha);
}
