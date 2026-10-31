class_name UI
## The look of every menu and of the HUD, which is everything the game's pixels
## aren't: full resolution, slanted, loud. Slabs at an angle, letters that slam
## in, sunbursts, a colour that never stops going round.

const INK := Color("0b0a14")
const INK_SOFT := Color("1b1830")
const WHITE := Color("ffffff")
const SOFT := Color("cbdbfc")
const DIM := Color("8f94b8")
const YELLOW := Color("fbf236")
const ORANGE := Color("ff8a1f")
const PINK := Color("ff2e7e")
const CYAN := Color("29e7ff")
const GREEN := Color("99e550")
const BLUE := Color("639bff")
const RED := Color("ff3b4e")
## How far over a slab's top leans, for its height.
const SLANT := 0.28
## How wide the soft edge of a flat shape is, each way.
const FEATHER := 0.8
const CORNER_STEPS := 4

## The sparks, flash and shake over everything, for whoever wants them (ui_fx.gd).
static var fx: UiFx

static var _display: Font
static var _body: Font
static var _pixel: Font


## Anything shouted: as smooth as the game's pixels aren't.
static func title_font() -> Font:
	return display_font()


## Unbounded Black: buttons and names.
static func display_font() -> Font:
	if _display == null:
		_display = load("res://assets/fonts/Unbounded-Black.ttf")
	return _display


## Lexend: anything to actually read.
static func body_font() -> Font:
	if _body == null:
		_body = load("res://assets/fonts/Lexend-SemiBold.ttf")
	return _body


## The one thing in the world that's lettered: the numbers on the clock.
static func pixel_font() -> Font:
	if _pixel == null:
		_pixel = load("res://assets/fonts/heading.fnt")
	return _pixel


## The colour that goes round, as the floor's does.
static func hue(offset := 0.0, saturation := 0.95, value := 1.0) -> Color:
	return Color.from_hsv(fposmod(Time.get_ticks_msec() * 0.00004 + offset, 1.0), saturation, value)


## `color` past white, so it blooms: the more `amount`, the more.
static func glow(color: Color, amount := 2.0) -> Color:
	return Color(color.r * amount, color.g * amount, color.b * amount, color.a)


## A soft streak, solid at `to` and gone by `from`.
static func streak(ci: CanvasItem, from: Vector2, to: Vector2, width: float, color: Color) -> void:
	var side := (to - from).orthogonal().normalized() * width * 0.5
	var clear := Color(color, 0.0)
	RenderingServer.canvas_item_add_triangle_array(ci.get_canvas_item(), PackedInt32Array([0, 1, 2, 0, 2, 3]),
		PackedVector2Array([from - side * 0.2, to - side, to + side, from + side * 0.2]), PackedColorArray([clear, color, color, clear]))


## A jagged comic star round `at`: rough, the same each time for the same `seed_value`.
static func star(ci: CanvasItem, at: Vector2, radius: Vector2, points: int, seed_value: int, grow: float, color: Color) -> void:
	var vertices := PackedVector2Array([at])
	var colors := PackedColorArray([color])
	var indices := PackedInt32Array()
	var count := points * 2
	for i in count:
		var rough := 0.78 + 0.22 * sin(float(i + seed_value) * 12.9898) * sin(float(i * 3 + seed_value) * 4.1414)
		var k := (1.0 if i % 2 == 0 else 0.62) * rough + grow
		vertices.append(at + Vector2.from_angle(TAU * i / count) * radius * k)
		colors.append(color)
		indices.append_array([0, i + 1, (i + 1) % count + 1])
	RenderingServer.canvas_item_add_triangle_array(ci.get_canvas_item(), indices, vertices, colors)


## A parallelogram: `rect`'s top pushed right, its bottom left, by `slant` of its
## height, with its corners rounded off.
static func slab(ci: CanvasItem, rect: Rect2, color: Color, slant := SLANT, corner := 9.0) -> void:
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var lean := rect.size.y * slant * 0.5
	var points := PackedVector2Array([
		rect.position + Vector2(lean, 0),
		rect.position + Vector2(rect.size.x + lean, 0),
		rect.position + Vector2(rect.size.x - lean, rect.size.y),
		rect.position + Vector2(-lean, rect.size.y),
	])
	fill(ci, round_corners(points, minf(corner, minf(rect.size.x, rect.size.y) * 0.3)), color)


## A rectangle that can be turned, unlike what draw_rect gives under a turned transform.
static func rect(ci: CanvasItem, area: Rect2, color: Color) -> void:
	fill(ci, PackedVector2Array([area.position, Vector2(area.end.x, area.position.y), area.end, Vector2(area.position.x, area.end.y)]), color)


## `points` (a convex shape, going round) with each corner cut into a curve.
static func round_corners(points: PackedVector2Array, radius: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	var n := points.size()
	for i in n:
		var corner := points[i]
		var before := points[(i + n - 1) % n]
		var after := points[(i + 1) % n]
		var from := corner + (before - corner).normalized() * minf(radius, corner.distance_to(before) * 0.5)
		var to := corner + (after - corner).normalized() * minf(radius, corner.distance_to(after) * 0.5)
		for step in CORNER_STEPS + 1:
			var t := float(step) / CORNER_STEPS
			out.append(from.lerp(corner, t).lerp(corner.lerp(to, t), t))
	return out


## A convex shape with a soft edge. This renderer has no 2D anti-aliasing, so every
## edge gets a thin strip fading out, in one triangle list.
static func fill(ci: CanvasItem, points: PackedVector2Array, color: Color) -> void:
	var n := points.size()
	if n < 3:
		return
	var middle := Vector2.ZERO
	for p in points:
		middle += p
	middle /= n
	var vertices := PackedVector2Array()
	var colors := PackedColorArray()
	vertices.resize(n * 2)
	colors.resize(n * 2)
	var clear := Color(color, 0.0)
	for i in n:
		var p := points[i]
		var a := (p - points[(i + n - 1) % n]).orthogonal().normalized()
		var b := (points[(i + 1) % n] - p).orthogonal().normalized()
		var out := (a + b).normalized()
		if out.dot(p - middle) < 0.0:
			out = -out
		var mitre := minf(1.0 / maxf(absf(out.dot(a)), 0.5), 2.0) * FEATHER
		vertices[i] = p - out * mitre
		vertices[i + n] = p + out * mitre
		colors[i] = color
		colors[i + n] = clear
	var indices := PackedInt32Array()
	for i in range(1, n - 1):
		indices.append_array([0, i, i + 1])
	for i in n:
		var j := (i + 1) % n
		indices.append_array([i, j, j + n, i, j + n, i + n])
	RenderingServer.canvas_item_add_triangle_array(ci.get_canvas_item(), indices, vertices, colors)


## A slab with a hard offset shadow and a bright edge, the thing most things sit on.
static func plate(ci: CanvasItem, rect: Rect2, color: Color, edge := YELLOW, slant := SLANT) -> void:
	slab(ci, Rect2(rect.position + Vector2(10, 10), rect.size), Color(0, 0, 0, 0.55), slant)
	slab(ci, rect.grow(4.0), edge, slant)
	slab(ci, rect, color, slant)


static func text_width(font: Font, text: String, size: int) -> float:
	return font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x


## Text with a thick outline, with `at` on its baseline, left end.
static func outlined(ci: CanvasItem, font: Font, at: Vector2, text: String, size: int, color: Color, outline := 0, outline_color := INK) -> void:
	if outline > 0:
		ci.draw_string_outline(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, outline, outline_color)
	ci.draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


## The same, centred on `at`, up and down too.
static func centred(ci: CanvasItem, font: Font, at: Vector2, text: String, size: int, color: Color, outline := 0, outline_color := INK) -> void:
	var w := text_width(font, text, size)
	outlined(ci, font, at + Vector2(-w * 0.5, size * 0.36), text, size, color, outline, outline_color)


## Everything drawn after this is at `at`, turned, scaled and leaning, till `straight`.
static func tilt(ci: CanvasItem, at: Vector2, rot := 0.0, scale := 1.0, skew := -0.18) -> void:
	ci.draw_set_transform_matrix(Transform2D(rot, Vector2(scale, scale), skew, at))


static func straight(ci: CanvasItem) -> void:
	ci.draw_set_transform_matrix(Transform2D.IDENTITY)


## A sunburst of `count` rays round `at`, each fading away to nothing as it goes out.
static func burst(ci: CanvasItem, at: Vector2, inner: float, outer: float, count: int, turned: float, color: Color) -> void:
	var step := TAU / count
	var vertices := PackedVector2Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()
	var clear := Color(color, 0.0)
	var part := PackedFloat32Array([0.0, 0.45, 1.0])
	var strength := PackedFloat32Array([1.0, 0.45, 0.0])
	for i in count:
		var a := turned + i * step
		var first := vertices.size()
		for k in part.size():
			var radius := lerpf(inner, outer, part[k])
			var half := step * lerpf(0.12, 0.28, part[k])
			var dir := Vector2.from_angle(a)
			var side := dir.orthogonal()
			var width := radius * tan(half)
			var mid := at + dir * radius
			var shade := Color(color, color.a * strength[k])
			# Across the ray: clear, solid, solid, clear, so its long edges are soft too.
			vertices.append_array([mid - side * (width + FEATHER * 1.5), mid - side * width, mid + side * width, mid + side * (width + FEATHER * 1.5)])
			colors.append_array([clear, shade, shade, clear])
		for k in part.size() - 1:
			for across in 3:
				var o := first + k * 4 + across
				indices.append_array([o, o + 1, o + 5, o, o + 5, o + 4])
	RenderingServer.canvas_item_add_triangle_array(ci.get_canvas_item(), indices, vertices, colors)


## A paragraph, word-wrapped to `width`.
static func paragraph(ci: CanvasItem, at: Vector2, text: String, width: float, size: int, color: Color, font: Font = null) -> void:
	ci.draw_multiline_string(font if font else body_font(), at, text, HORIZONTAL_ALIGNMENT_LEFT, width, size, -1, color)


## An ease with a bounce past the end: 0 to 1, 1 and a bit in the middle.
static func back_out(t: float, overshoot := 1.9) -> float:
	var k := clampf(t, 0.0, 1.0) - 1.0
	return 1.0 + k * k * ((overshoot + 1.0) * k + overshoot)


static func cubic_out(t: float) -> float:
	var k := 1.0 - clampf(t, 0.0, 1.0)
	return 1.0 - k * k * k


## A column of buttons in order, wired so the sticks and the arrows go through them.
static func link_focus(buttons: Array) -> void:
	for i in buttons.size():
		var b: Control = buttons[i]
		b.focus_neighbor_top = b.get_path_to(buttons[wrapi(i - 1, 0, buttons.size())])
		b.focus_neighbor_bottom = b.get_path_to(buttons[wrapi(i + 1, 0, buttons.size())])
		b.focus_neighbor_left = b.get_path()
		b.focus_neighbor_right = b.get_path()


static func format_time(seconds: float) -> String:
	var s := int(seconds)
	return "%d:%02d" % [s / 60, s % 60]


## "12 345": big numbers, readable.
static func format_score(score: int) -> String:
	var text := str(score)
	var out := ""
	while text.length() > 3:
		out = " " + text.substr(text.length() - 3) + out
		text = text.substr(0, text.length() - 3)
	return text + out
