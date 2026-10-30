class_name Logo
extends Control
## The original's logo: SUPER SMASK ZERO, in its font, breathing between 80% and
## full, and rocking two degrees either way over four seconds.

const WORDS := ["SUPER", "SMASK", "ZERO"]

var _time := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(300, 98)


func _process(delta: float) -> void:
	_time += delta
	var wave := sin(_time * PI * 0.5)
	rotation_degrees = wave * 2.0
	modulate.a = 0.9 + wave * 0.1
	pivot_offset = size * 0.5
	queue_redraw()


func _draw() -> void:
	var font := UI.big_font()
	var y := 26.0
	for i in WORDS.size():
		var word: String = WORDS[i]
		var width := font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, UI.BIG_SIZE).x
		var x := (size.x - width) * 0.5
		var color := UI.ACCENT if word == "SMASK" else UI.INK
		if word == "ZERO":
			color = Sprites.hsl(_time * 0.1, 0.9, 0.65)
		for offset: Vector2 in [Vector2(2, 3), Vector2(1, 2), Vector2(0, 2)]:
			draw_string(font, Vector2(x, y) + offset, word, HORIZONTAL_ALIGNMENT_LEFT, -1, UI.BIG_SIZE, Color.BLACK)
		draw_string(font, Vector2(x, y), word, HORIZONTAL_ALIGNMENT_LEFT, -1, UI.BIG_SIZE, color)
		y += 30.0
