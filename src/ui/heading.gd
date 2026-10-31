class_name Heading
extends Control
## A screen's title: huge, leaning, on a slab, slamming in from too close.

var text := ""
var font_size := 84
var color := UI.YELLOW
var _t := 0.0


func _init(shown := "", size_of_font := 84, shown_color := UI.YELLOW) -> void:
	text = shown
	font_size = size_of_font
	color = shown_color
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size.y = font_size * 1.6


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if _t < 1.0:
		_t = minf(_t + delta / 0.32, 1.0)
		if _t >= 1.0 and UI.fx:
			UI.fx.shake(18.0)
	queue_redraw()


func _draw() -> void:
	var font := UI.title_font()
	var w := UI.text_width(font, text, font_size)
	var k := UI.back_out(_t, 1.2)
	var at := Vector2(30.0, size.y * 0.5)
	var plate := Rect2(Vector2(-60.0, -font_size * 0.62), Vector2(w + 170.0, font_size * 1.24))
	UI.tilt(self, at + Vector2((1.0 - k) * -1400.0, 0), -0.03, 1.0, 0.0)
	UI.plate(self, plate, UI.INK, UI.glow(color, 1.6), 0.35)
	UI.tilt(self, at + Vector2((1.0 - UI.cubic_out(_t)) * -700.0, 0), -0.03, 1.0 + (1.0 - _t) * 1.4, -0.14)
	draw_string(font, Vector2(4, font_size * 0.36 + 5), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, UI.PINK)
	draw_string(font, Vector2(0, font_size * 0.36), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
	UI.straight(self)
