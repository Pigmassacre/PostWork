shader_type canvas_item;
// Letters filled with a chrome gradient, top to bottom in canvas space, with a
// glint sweeping across them now and then.

uniform vec4 top = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 middle = vec4(1.0, 0.95, 0.2, 1.0);
uniform vec4 bottom = vec4(1.0, 0.45, 0.1, 1.0);
uniform float from_y = 0.0;
uniform float to_y = 100.0;

varying vec2 local;

void vertex() {
	local = VERTEX;
}

void fragment() {
	vec4 glyph = COLOR * texture(TEXTURE, UV);
	float t = clamp((local.y - from_y) / (to_y - from_y), 0.0, 1.0);
	vec3 fill = t < 0.48 ? mix(top.rgb, middle.rgb, t / 0.48) : mix(middle.rgb, bottom.rgb, (t - 0.48) / 0.52);
	float sweep = fract(TIME * 0.22) * 3.0 - 1.0;
	float glint = 1.0 - smoothstep(0.0, 0.09, abs((local.x + local.y * 0.6) * 0.012 - sweep));
	fill = mix(fill, vec3(2.4), glint * 0.85);
	COLOR = vec4(fill, glyph.a);
}
