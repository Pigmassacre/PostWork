shader_type canvas_item;
// The floor, at full resolution: big tiles with a plus where they meet, lit from over
// the middle, with its glowing wall round it and a soft shadow thrown on the city.

uniform vec2 area = vec2(1200.0, 700.0);
uniform float margin = 64.0;
uniform float unit = 4.0;
uniform float clock = 0.0;
uniform float pop = 0.0;
uniform float wall_hit = 0.0;
uniform vec4 tint = vec4(0.4, 0.25, 0.12, 1.0);
uniform vec4 edge = vec4(1.0, 1.0, 0.3, 1.0);

float h2(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float rounded(vec2 c, vec2 half_size, float radius) {
	vec2 d = abs(c) - half_size + radius;
	return length(max(d, vec2(0.0))) + min(max(d.x, d.y), 0.0) - radius;
}

void fragment() {
	vec2 c = UV * (area + vec2(margin * 2.0)) - margin - area * 0.5;
	float d = rounded(c, area * 0.5, unit);
	float shadow = 0.55 * (1.0 - smoothstep(-unit * 2.0, unit * 9.0, rounded(c - vec2(4.0, 7.0) * unit, area * 0.5, unit * 2.0)));
	float tile = unit * 16.0;
	vec2 cell = floor(c / tile);
	vec2 local = c - cell * tile;
	vec2 from_line = min(local, tile - local);
	float z = h2(cell);
	float checker = mod(cell.x + cell.y, 2.0);
	vec3 col = tint.rgb * (0.94 + checker * 0.1 + (z - 0.5) * 0.07);
	// Now and then a tile comes up, and goes again.
	if (z > 0.86) {
		col += tint.rgb * 0.22 * pow(0.5 + 0.5 * sin(clock * 0.9 + z * 90.0), 6.0);
	}
	// A slow bar of light going across it.
	float sweep = fract((c.x + c.y * 0.6) / (area.x * 1.6) - clock * 0.035);
	col += tint.rgb * 0.1 * smoothstep(0.0, 0.08, sweep) * smoothstep(0.2, 0.08, sweep);
	// The joins between tiles, and a plus where they meet.
	float line = min(from_line.x, from_line.y);
	col = mix(col, tint.rgb * 0.68, smoothstep(unit * 0.32, unit * 0.2, line));
	float arm = unit * 2.0;
	float wide = unit * 0.4;
	float plus = max(
		smoothstep(wide + 0.7, wide - 0.7, from_line.x) * smoothstep(arm + 0.7, arm - 0.7, from_line.y),
		smoothstep(wide + 0.7, wide - 0.7, from_line.y) * smoothstep(arm + 0.7, arm - 0.7, from_line.x));
	col = mix(col, tint.rgb * (1.55 + pop * 1.6), plus);
	// Lit from over the middle, going dark into the walls.
	vec2 off = c / (area * 0.5);
	col *= mix(1.2, 0.68, dot(off, off) * 0.5);
	col *= mix(0.72, 1.0, smoothstep(0.0, unit * 8.0, -d));
	vec3 result = col;
	float alpha = 1.0;
	// Outside the floor: the wall's outer line and the shadow.
	if (d > 0.0) {
		float wall = smoothstep(unit * 2.0 + 0.8, unit * 2.0 - 0.8, d);
		float halo = smoothstep(unit * 4.0 + 0.8, unit * 4.0 - 0.8, d) * 0.3;
		alpha = max(shadow, max(wall, halo));
		vec3 lit = edge.rgb * (1.6 + wall_hit * 1.5);
		result = mix(vec3(0.0), lit, max(wall, halo) / max(alpha, 0.001));
	}
	COLOR = vec4(result, alpha);
}
