class_name SmaskButton
extends Button
## The menus' button: a slab that's dark until it's chosen, when yellow wipes across
## it, it jumps out with a bounce, sparks fly and a sunburst turns behind it.
## Pressing it slams it. It draws everything itself. A row of the options is one of
## these too: `value` is what's shown on the right, `fill` a bar of segments.

const WIPE_TIME := 0.12
const IN_TIME := 0.36

var label := ""
var font_size := 34
var value := ""
## 0 to 1 for a bar of segments; below 0, no bar.
var fill := -1.0
## How far over its whole layout it's shoved, for columns that follow a slant.
var indent := 0.0
## Which of a column it is, for the pitch of its tick.
var index := 0
var accent := UI.YELLOW

var _lit := 0.0
var _pop := 0.0
var _pop_vel := 0.0
var _press := 0.0
var _in := 1.0
var _delay := 0.0
var _slide := 0.0


func _init(text_shown := "", size_of_font := 34) -> void:
	label = text_shown
	font_size = size_of_font


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	focus_mode = Control.FOCUS_ALL
	custom_minimum_size.y = maxf(custom_minimum_size.y, font_size * 1.9)
	var empty := StyleBoxEmpty.new()
	for state in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
		add_theme_stylebox_override(state, empty)
	# Only a pointer that's really moving: a window can open with one already over a button.
	gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseMotion and event.relative.length() > 0.5 and not disabled and not has_focus():
			grab_focus()
	)
	focus_entered.connect(_on_focus)
	pressed.connect(_on_press)


func pop_in(delay: float) -> void:
	_delay = delay
	_in = 0.0


func _on_focus() -> void:
	z_index = 2
	_pop_vel = 7.0
	Audio.play("tick", -9.0, 1.0 + index * 0.09)
	if UI.fx and _in >= 1.0:
		UI.fx.sparks(global_position + Vector2(indent + 20.0, size.y * 0.5), accent, 7, 420.0)


func _on_press() -> void:
	_press = 1.0
	_pop_vel = -9.0
	Audio.play("accept", -5.0)
	if UI.fx:
		UI.fx.sparks(global_position + Vector2(indent, 0) + size * 0.5, accent, 22, 900.0)
		UI.fx.ring(global_position + Vector2(indent, 0) + size * 0.5, 260.0, accent)
		UI.fx.shake(16.0)


func _process(delta: float) -> void:
	if _delay > 0.0:
		_delay -= delta
	elif _in < 1.0:
		_in = minf(_in + delta / IN_TIME, 1.0)
	var focused := has_focus() and not disabled
	if not focused and z_index != 0:
		z_index = 0
	_lit = move_toward(_lit, 1.0 if focused else 0.0, delta / WIPE_TIME)
	_slide = lerpf(_slide, 1.0 if focused else 0.0, clampf(delta * 18.0, 0.0, 1.0))
	# A spring, for the bounce.
	_pop_vel += (-_pop * 260.0 - _pop_vel * 16.0) * delta
	_pop += _pop_vel * delta
	_press = maxf(_press - delta * 4.0, 0.0)
	queue_redraw()


func _draw() -> void:
	if _in <= 0.0:
		return
	var enter := UI.back_out(_in)
	var at := Vector2(indent + (1.0 - enter) * -900.0 + _slide * 26.0, 0)
	var scale_now := 1.0 + _pop * 0.5
	var mid := size * 0.5
	draw_set_transform_matrix(Transform2D(0.0, Vector2(scale_now, scale_now), 0.0, at + mid))
	var r := Rect2(-mid, size)
	var focused := _lit > 0.0
	if focused:
		var turning := Time.get_ticks_msec() * 0.0015
		# Small enough to keep off the rows either side.
		var reach := size.y * 0.72
		UI.burst(self, r.position + Vector2(-reach * 0.4, size.y * 0.5), reach * 0.45, reach * (0.75 + 0.25 * _lit), 10, turning, Color(UI.glow(UI.hue(0.45), 1.8), _lit))
	UI.slab(self, Rect2(r.position + Vector2(8, 8), r.size), Color(0, 0, 0, 0.55))
	UI.slab(self, r, UI.INK if not disabled else Color(UI.INK_SOFT, 0.6))
	if focused:
		var wipe := r
		wipe.size.x *= UI.cubic_out(_lit)
		UI.slab(self, wipe.grow(2.0), UI.glow(accent, 1.5))
		UI.slab(self, wipe, accent)
	if _press > 0.0:
		UI.slab(self, r, Color(1, 1, 1, _press))
	var color := UI.WHITE.lerp(UI.INK, _lit)
	if disabled:
		color = UI.DIM
	var baseline := font_size * 0.36
	var left := r.position.x + font_size * 0.8
	var font := UI.display_font()
	if fill < 0.0 and value == "":
		var w := UI.text_width(font, label, font_size)
		left = -w * 0.5 if alignment == HORIZONTAL_ALIGNMENT_CENTER else left
	draw_string(font, Vector2(left, baseline), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
	if fill >= 0.0:
		_draw_bar(r, color)
	if value != "":
		var w := UI.text_width(font, value, font_size)
		var right := r.end.x - font_size * 0.9
		if fill >= 0.0:
			right -= 220.0
		draw_string(font, Vector2(right - w, baseline), value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
	draw_set_transform_matrix(Transform2D.IDENTITY)


func _draw_bar(r: Rect2, color: Color) -> void:
	var count := 10
	var w := 18.0
	var h := size.y * 0.52
	var x := r.end.x - font_size * 0.8 - count * (w + 3.0)
	for i in count:
		var on := float(i) + 0.5 < fill * count
		var cell := Rect2(Vector2(x + i * (w + 3.0), -h * 0.5), Vector2(w, h))
		UI.slab(self, cell, color if on else Color(color, 0.18))
