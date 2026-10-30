class_name Sprites
## The sprites, loaded once.

static var _cache := {}


static func get_tex(sprite: String) -> Texture2D:
	if not _cache.has(sprite):
		_cache[sprite] = load("res://assets/sprites/%s.png" % sprite)
	return _cache[sprite]


## Draws `tex` on `canvas`, centred on `pos`, turned by `rot`.
static func draw(canvas: CanvasItem, tex: Texture2D, pos: Vector2, rot := 0.0, color := Color.WHITE, scale := 1.0) -> void:
	canvas.draw_set_transform(pos.round(), rot, Vector2(scale, scale))
	canvas.draw_texture(tex, -tex.get_size() * 0.5, color)
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)


## The original's colours came from this: hue, saturation and lightness, 0 to 1.
static func hsl(h: float, s: float, l: float, a := 1.0) -> Color:
	var v := l + s * minf(l, 1.0 - l)
	var sv := 0.0 if v <= 0.0 else 2.0 * (1.0 - l / v)
	return Color.from_hsv(fposmod(h, 1.0), sv, v, a)
