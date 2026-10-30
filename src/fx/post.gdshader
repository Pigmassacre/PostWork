shader_type canvas_item;
// Over the whole picture: rings of shock pushing the pixels about, colours coming
// apart when something big happens, a flash, the scanlines of an old set.

uniform sampler2D screen: hint_screen_texture, filter_nearest, repeat_disable;
uniform vec4 ripples[4];
uniform float aspect = 1.777;
uniform float aberration = 0.0;
uniform vec4 flash_color = vec4(0.0);
uniform float scanlines = 0.0;
uniform float pixel_height = 270.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	for (int i = 0; i < 4; i++) {
		vec4 r = ripples[i];
		if (r.w > 0.0) {
			vec2 d = uv - r.xy;
			d.x *= aspect;
			float dist = length(d);
			float front = r.z * 0.55;
			float band = 1.0 - smoothstep(0.0, 0.05, abs(dist - front));
			uv -= normalize(d + 0.0001) * band * r.w * 0.018 * (1.0 - r.z) / vec2(aspect, 1.0);
		}
	}
	vec3 color;
	if (aberration > 0.001) {
		vec2 off = (uv - 0.5) * aberration * 0.012;
		color = vec3(texture(screen, uv + off).r, texture(screen, uv).g, texture(screen, uv - off).b);
	} else {
		color = texture(screen, uv).rgb;
	}
	color = mix(color, flash_color.rgb, flash_color.a * 0.5);
	// A little vignette, and the scanlines.
	vec2 v = SCREEN_UV - 0.5;
	color *= 1.0 - dot(v, v) * 0.55;
	if (scanlines > 0.0) {
		float line = fract(SCREEN_UV.y * pixel_height);
		color *= 1.0 - scanlines * 0.14 * smoothstep(0.55, 1.0, line);
	}
	COLOR = vec4(color, 1.0);
}
