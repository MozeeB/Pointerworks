shader_type canvas_item;
// target_pulse — soft sinusoidal brightness pulse for unhit targets.
//
// Apply to Target's Polygon2D children via a ShaderMaterial. Once the
// Target is marked hit, the script swaps material_override to null so
// the pulse stops and the static hit color shows.

uniform float pulse_speed : hint_range(0.1, 6.0) = 1.8;
uniform float pulse_min : hint_range(0.0, 1.0) = 0.65;
uniform float pulse_max : hint_range(0.0, 2.0) = 1.25;

void fragment() {
	float t = 0.5 + 0.5 * sin(TIME * pulse_speed);
	float k = mix(pulse_min, pulse_max, t);
	vec4 base = texture(TEXTURE, UV);
	// Polygon2D without a texture samples white; multiply COLOR.
	vec4 final = base * COLOR;
	final.rgb *= k;
	COLOR = final;
}
