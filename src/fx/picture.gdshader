shader_type canvas_item;
render_mode blend_premul_alpha;
// Puts the game's low-res picture on the screen with the colours it was drawn in.
// It's drawn in plain sRGB, but the UI's screen is HDR, and works in linear light, so
// without this the picture comes out far too dark. Where nothing's been drawn it's
// see-through, down to the city and the floor, and what's in it is premultiplied.

void fragment() {
	vec4 s = texture(TEXTURE, UV);
	vec3 c = min(s.rgb / max(s.a, 0.001), vec3(1.0));
	c = mix(c * 12.92, 1.055 * pow(max(c, vec3(0.0)), vec3(1.0 / 2.4)) - 0.055, step(0.0031308, c));
	COLOR = vec4(c * s.a, s.a);
}
