shader_type canvas_item;
// Behind the menus: a sunburst going slowly round, in the hour's colour, with a
// halftone of dots coming in towards the edges.

uniform float hue = 0.0;
uniform vec2 centre = vec2(0.3, 0.45);
uniform float aspect = 1.778;
uniform float brightness = 1.0;

vec3 hsv(float h, float s, float v) {
	vec3 k = clamp(abs(mod(h * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
	return v * mix(vec3(1.0), k, s);
}

void fragment() {
	vec2 p = (UV - centre) * vec2(aspect, 1.0);
	float angle = atan(p.y, p.x);
	float dist = length(p);
	float turn = angle * 16.0 / 6.28318 + TIME * 0.05;
	// Soft-edged, and it stays soft where the angle wraps.
	float soft = min(fwidth(turn), 0.06);
	float ray = smoothstep(0.25 - soft, 0.25 + soft, abs(fract(turn) - 0.5));
	vec3 color = mix(hsv(hue, 0.85, 0.2), hsv(hue + 0.05, 0.95, 0.33), ray) * brightness;
	// The dots: in a slanted grid, bigger the further out.
	vec2 cell = vec2(p.x + p.y * 0.3, p.y) * 46.0;
	float dot_size = clamp(dist * 0.5 - 0.08, 0.0, 0.5);
	float dots = 1.0 - smoothstep(dot_size - 0.03, dot_size + 0.03, length(fract(cell) - 0.5));
	color = mix(color, vec3(0.03, 0.02, 0.07), dots * 0.75);
	COLOR = vec4(color, 1.0);
}
