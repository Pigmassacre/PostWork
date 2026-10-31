shader_type canvas_item;
// What's behind the floor, at full resolution: the sky going from sunset to a starry
// night, the sun and moon, clouds, towers in three layers with their windows coming on
// as people get home, a commuter train and the traffic. Worked out in the 1920 by 1080
// of the UI.

uniform vec2 screen = vec2(1920.0, 1080.0);
uniform float night = 0.0;
uniform float clock = 0.0;
uniform float camera_x = 0.0;
uniform vec4 sky_top = vec4(0.2, 0.1, 0.4, 1.0);
uniform vec4 sky_bottom = vec4(1.0, 0.5, 0.2, 1.0);

const vec3 DEEP = vec3(0.027, 0.02, 0.102);

float h1(float n) {
	return fract(sin(n * 127.1) * 43758.5453);
}

float h2(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(h2(i), h2(i + vec2(1.0, 0.0)), f.x), mix(h2(i + vec2(0.0, 1.0)), h2(i + vec2(1.0, 1.0)), f.x), f.y);
}

float box(vec2 p, vec2 from, vec2 to) {
	vec2 d = min(p - from, to - p);
	return clamp(min(d.x, d.y) + 0.5, 0.0, 1.0);
}

vec3 window_color(float z) {
	float pick = fract(z * 37.0);
	if (pick < 0.25) return vec3(0.984, 0.949, 0.212);
	if (pick < 0.5) return vec3(1.0, 0.76, 0.29);
	if (pick < 0.75) return vec3(0.933, 0.765, 0.604);
	return vec3(0.373, 0.804, 0.894);
}

// One row of towers: x from the middle of the screen, y up from the bottom.
void towers(inout vec3 col, vec2 p, float width, float tallest, float seed, vec3 body, vec2 pitch, vec2 pane, float pane_alpha, float lit_share) {
	float i = floor(p.x / width);
	float f = p.x - i * width;
	float r1 = h1(i + seed);
	float r2 = h1(i + seed + 0.37);
	float r3 = h1(i + seed + 0.71);
	float r4 = h1(i + seed + 0.13);
	// Lower in the middle, where the floor hides them; tall towers at the sides.
	float side = clamp(abs(i * width + width * 0.5) / 960.0, 0.0, 1.0);
	float top = tallest * mix(0.35, 1.0, side * side) * mix(0.5, 1.0, r1);
	float left = width * (0.03 + 0.1 * r2);
	float right = width - width * (0.03 + 0.1 * r3);
	// A setback on some, and the block's own top if it's above this bit.
	float setback = top * (0.62 + 0.2 * r3);
	float narrow = width * (0.12 + 0.14 * r4);
	if (r3 > 0.35 && p.y > setback) {
		left += narrow;
		right -= narrow;
	}
	float middle = (left + right) * 0.5;
	// A mast on a few, with its red light.
	if (r4 > 0.7) {
		float mast_top = top + 40.0 + 60.0 * r1;
		col = mix(col, body, box(vec2(f, p.y), vec2(middle - 1.5, top - 2.0), vec2(middle + 1.5, mast_top)));
		float blink = smoothstep(0.75, 1.0, sin(clock * 2.0 + r1 * 20.0)) * smoothstep(0.2, 0.6, night);
		float d = length(vec2(f - middle, p.y - mast_top));
		col += vec3(1.0, 0.15, 0.1) * blink * (smoothstep(5.0, 3.0, d) + 0.4 * exp(-d * 0.14));
	}
	float inside = box(vec2(f, p.y), vec2(left, -10.0), vec2(right, top));
	if (inside <= 0.0) {
		return;
	}
	float up = clamp(p.y / max(top, 1.0), 0.0, 1.0);
	vec3 c = mix(body * 0.86, body * 1.18, up);
	// The sunset catches one side.
	c = mix(c, sky_bottom.rgb, (1.0 - night) * 0.38 * smoothstep(right - 7.0, right - 1.0, f));
	c = mix(c, body * 0.65, smoothstep(left + 5.0, left, f));
	if (pane.x > 0.0) {
		vec2 at = vec2(f - left - 6.0, p.y - 8.0);
		vec2 cell = floor(at / pitch);
		vec2 local = at - cell * pitch;
		vec2 span = vec2(right - left - 12.0, top - 18.0);
		if (at.x >= 0.0 && at.y >= 0.0 && cell.x * pitch.x + pane.x <= span.x && cell.y * pitch.y + pane.y <= span.y) {
			float z = h2(cell + vec2(i + seed, seed));
			float there = box(local, vec2(0.0), pane);
			if (fract(z * 3.1) < 0.8) {
				// A dark one still has the sky in it.
				vec3 glass = mix(c, mix(sky_top.rgb, sky_bottom.rgb, 0.6), 0.2);
				c = mix(c, glass, there);
				if (z < lit_share) {
					vec3 light = window_color(z);
					// A few have a television on.
					if (fract(z * 997.0) < 0.08) {
						light = mix(vec3(0.62, 0.85, 1.0), vec3(0.37, 0.44, 1.0), 0.5 + 0.5 * sin(clock * (4.0 + z * 9.0) + cell.x));
					}
					c = mix(c, light, there * pane_alpha);
				}
			}
		}
	}
	col = mix(col, c, inside);
}

void sky(inout vec3 col, vec2 p) {
	float v = p.y / screen.y;
	vec2 grid = floor(p / 46.0);
	vec2 local = p - grid * 46.0;
	// Stars.
	float shown = clamp((night - 0.3) / 0.5, 0.0, 1.0);
	if (shown > 0.0 && h2(grid) > 0.55) {
		vec2 star = vec2(h2(grid + 3.1), h2(grid + 7.7)) * 40.0 + 3.0;
		float z = h2(grid + 1.3);
		float twinkle = 0.55 + 0.45 * sin(clock * (1.0 + z * 3.0) + z * 40.0);
		float size = 0.8 + z * z * 1.8;
		col += vec3(1.0, 0.97, 0.9) * smoothstep(size + 0.8, size - 0.4, length(local - star)) * shown * twinkle * (1.0 - v * v);
	}
	// The sun goes down on the right.
	float sun_t = clamp(night / 0.5, 0.0, 1.0);
	if (sun_t < 1.0) {
		vec2 sun = vec2(screen.x * 0.5 + 780.0 - camera_x * 0.3, mix(screen.y * 0.42, screen.y + 170.0, sun_t));
		float radius = 150.0;
		vec2 d = p - sun;
		float dist = length(d);
		col += vec3(1.0, 0.42, 0.25) * exp(-dist / 210.0) * 0.55 * (1.0 - sun_t * 0.6);
		// Slats, wider towards the bottom.
		float slat = 1.0;
		if (d.y > 8.0) {
			float gap = mix(0.1, 0.6, clamp(d.y / radius, 0.0, 1.0));
			float s = fract((d.y + clock * 22.0) / 34.0);
			slat = smoothstep(gap - 0.03, gap + 0.03, s);
		}
		float disc = smoothstep(radius + 1.0, radius - 1.0, dist) * slat;
		col = mix(col, mix(vec3(1.0, 0.949, 0.478), vec3(1.0, 0.247, 0.498), clamp((d.y + radius) / (radius * 2.0), 0.0, 1.0)) * 1.15, disc);
	}
	// The moon comes up on the left.
	float moon_t = clamp((night - 0.45) / 0.45, 0.0, 1.0);
	if (moon_t > 0.0) {
		vec2 moon = vec2(screen.x * 0.5 - 800.0 - camera_x * 0.2, mix(screen.y + 80.0, 176.0, moon_t));
		float dist = length(p - moon);
		col += vec3(0.6, 0.65, 1.0) * exp(-dist / 120.0) * 0.3;
		float lit = smoothstep(61.0, 59.0, dist) * smoothstep(51.0, 53.0, length(p - moon - vec2(22.0, -13.0)));
		col = mix(col, vec3(0.933, 0.941, 1.0) * 1.1, lit);
	}
	// Clouds, long and thin.
	if (v < 0.72) {
		float drift = clock * (9.0 + v * 22.0);
		vec2 q = vec2((p.x + drift) * 0.0035, p.y * 0.03);
		float n = noise(q) * 0.65 + noise(q * 2.3 + 4.0) * 0.35;
		float cloud = smoothstep(0.6, 0.74, n) * smoothstep(0.72, 0.5, v);
		vec3 tint = mix(sky_bottom.rgb, vec3(1.0), 0.28 * (1.0 - night));
		col = mix(col, tint, cloud * mix(0.72, 0.2, night));
	}
}

void ground(inout vec3 col, vec2 p) {
	float y = p.y;
	if (y > 110.0) {
		return;
	}
	// The viaduct, and the 17:42 going over it.
	col = mix(col, DEEP, box(p, vec2(-99999.0, 54.0), vec2(99999.0, 62.0)));
	float pier = mod(p.x, 190.0);
	col = mix(col, DEEP, box(vec2(pier, y), vec2(0.0, 20.0), vec2(16.0, 56.0)));
	float nose = mod(clock * 330.0, screen.x + 3400.0) - 1100.0 - screen.x * 0.5;
	float back = nose - p.x;
	if (back > -60.0 && back < 660.0) {
		float car = floor(back / 110.0);
		float inside_car = back - car * 110.0;
		if (car >= 0.0 && car < 6.0) {
			vec2 q = vec2(inside_car, y - 62.0);
			col = mix(col, vec3(0.063, 0.063, 0.165), box(q, vec2(2.0, 0.0), vec2(106.0, 30.0)));
			float pane = mod(inside_car - 8.0, 19.0);
			col = mix(col, vec3(1.0, 0.886, 0.478), box(vec2(pane, y - 62.0), vec2(0.0, 12.0), vec2(12.0, 24.0)) * step(8.0, inside_car) * step(inside_car, 98.0));
		}
		float lamp = length(vec2(back, y - 74.0));
		col += vec3(1.0, 0.95, 0.75) * (smoothstep(5.0, 3.0, lamp) + 0.35 * exp(-lamp * 0.05));
	}
	// The road, with head and tail lights each way.
	col = mix(col, DEEP, box(p, vec2(-99999.0, -10.0), vec2(99999.0, 24.0)));
	if (y < 44.0) {
		float bright = mix(0.65, 1.0, night);
		float width = screen.x + 160.0;
		for (int i = 0; i < 18; i++) {
			float n = float(i);
			bool away = i % 2 == 0;
			float speed = 150.0 + mod(n * 29.0, 92.0);
			float x = mod(n * 331.0 + clock * speed * (away ? 1.0 : -1.0), width) - width * 0.5;
			float lane = away ? 15.0 : 7.0;
			vec3 light = away ? vec3(1.0, 0.25, 0.31) : vec3(1.0, 0.95, 0.69);
			vec2 d = vec2(p.x - x, y - lane);
			col = mix(col, light, box(d, vec2(-5.0, -1.5), vec2(5.0, 1.5)) * bright);
			col += light * exp(-length(d * vec2(0.09, 0.3))) * 0.22 * bright;
		}
	}
}

void fragment() {
	vec2 at = UV * screen;
	vec2 p = vec2(at.x, screen.y - at.y);
	float v = at.y / screen.y;
	vec3 col = mix(sky_top.rgb, sky_bottom.rgb, v * v);
	sky(col, at);
	float lit = mix(0.12, 0.72, night);
	vec3 far_body = mix(mix(sky_bottom.rgb, sky_top.rgb, 0.35), DEEP, 0.5);
	vec3 mid_body = mix(mix(sky_bottom.rgb, sky_top.rgb, 0.35), DEEP, 0.72);
	vec3 near_body = mix(mix(sky_bottom.rgb, sky_top.rgb, 0.35), DEEP, 0.93);
	vec2 far_p = vec2(at.x - screen.x * 0.5 - camera_x * 0.2, p.y);
	vec2 mid_p = vec2(at.x - screen.x * 0.5 - camera_x * 0.5, p.y);
	vec2 near_p = vec2(at.x - screen.x * 0.5 - camera_x, p.y);
	towers(col, far_p, 150.0, 690.0, 11.0, far_body, vec2(0.0), vec2(0.0), 0.0, 0.0);
	towers(col, far_p + 60.0, 96.0, 610.0, 23.0, far_body, vec2(0.0), vec2(0.0), 0.0, 0.0);
	towers(col, mid_p, 130.0, 570.0, 37.0, mid_body, vec2(13.0, 16.0), vec2(6.0, 8.0), 0.6, lit);
	towers(col, mid_p + 40.0, 84.0, 480.0, 41.0, mid_body, vec2(13.0, 16.0), vec2(6.0, 8.0), 0.6, lit);
	towers(col, near_p, 170.0, 420.0, 53.0, near_body, vec2(20.0, 26.0), vec2(11.0, 15.0), 0.9, lit);
	towers(col, near_p + 90.0, 116.0, 340.0, 67.0, near_body, vec2(20.0, 26.0), vec2(11.0, 15.0), 0.9, lit);
	ground(col, near_p);
	// Enough grain to keep the long gradients from banding.
	col += (h2(at) - 0.5) / 160.0;
	COLOR = vec4(col, 1.0);
}
