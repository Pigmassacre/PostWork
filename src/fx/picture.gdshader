shader_type canvas_item;
// Puts the game's low-res picture on the screen with the colours it was drawn in.
// It's drawn in plain sRGB, but the UI's screen is HDR, and works in linear light, so
// without this the picture comes out far too dark.

void fragment() {
	vec3 c = texture(TEXTURE, UV).rgb;
	COLOR = vec4(mix(c * 12.92, 1.055 * pow(max(c, vec3(0.0)), vec3(1.0 / 2.4)) - 0.055, step(0.0031308, c)), 1.0);
}
