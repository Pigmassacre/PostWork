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


## A parallelogram: `rect`'s top pushed right, its bottom left, by `slant` of its height.
static func slab(ci: CanvasItem, rect: Rect2, color: Color, slant := SLANT) -> void:
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var lean := rect.size.y * slant * 0.5
	var points := PackedVector2Array([
		rect.position + Vector2(lean, 0),
		rect.position + Vector2(rect.size.x + lean, 0),
		rect.position + Vector2(rect.size.x - lean, rect.size.y),
		rect.position + Vector2(-lean, rect.size.y),
	])
	ci.draw_colored_polygon(points, color)


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


## A sunburst of `count` rays round `at`.
static func burst(ci: CanvasItem, at: Vector2, inner: float, outer: float, count: int, turned: float, color: Color) -> void:
	var step := TAU / count
	for i in count:
		var a := turned + i * step
		ci.draw_colored_polygon(PackedVector2Array([
			at + Vector2.from_angle(a - step * 0.12) * inner,
			at + Vector2.from_angle(a - step * 0.28) * outer,
			at + Vector2.from_angle(a + step * 0.28) * outer,
			at + Vector2.from_angle(a + step * 0.12) * inner,
		]), color)


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
