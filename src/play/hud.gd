class_name Hud
extends Control
## The score, the clock, the multiplier, the hull, what's been taken, and the
## big words across the middle. All drawn, on the game's own pixels.

var world: World
var _banner_big := ""
var _banner_small := ""
var _banner_color := Color.WHITE
var _banner_time := 0.0
var _hint := ""
var _hint_time := 0.0
var _shown_score := 0.0
var _mult_pop := 0.0
var _last_mult := 1
var _boss_shown := 1.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func banner(big: String, small: String, color: Color) -> void:
	_banner_big = big
	_banner_small = small
	_banner_color = color
	_banner_time = 2.0


func clear_banner() -> void:
	_banner_time = 0.0


func hint(text: String, seconds := 6.0) -> void:
	_hint = text
	_hint_time = seconds


func _process(delta: float) -> void:
	_banner_time = maxf(_banner_time - delta, 0.0)
	_hint_time = maxf(_hint_time - delta, 0.0)
	_mult_pop = maxf(_mult_pop - delta * 5.0, 0.0)
	var run := world.run
	_shown_score = move_toward(_shown_score, float(run.score), maxf(float(run.score) - _shown_score, 60.0) * delta * 8.0)
	if run.multiplier() != _last_mult:
		if run.multiplier() > _last_mult:
			_mult_pop = 1.0
		_last_mult = run.multiplier()
	queue_redraw()


func _text(at: Vector2, text: String, font: Font, size: int, color: Color) -> void:
	draw_string(font, at + Vector2(1, 1), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(0, 0, 0, color.a))
	draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


func _centred(y: float, text: String, font: Font, size: int, color: Color) -> void:
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var at := Vector2(floorf((self.size.x - width) * 0.5), y)
	# Thick, so it reads over anything.
	for o: Vector2 in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1), Vector2(1, 2), Vector2(2, 2)]:
		draw_string(font, at + o, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(0, 0, 0, color.a))
	draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


func _draw() -> void:
	var run := world.run
	var heading := UI.heading_font()
	var body := UI.body_font()
	var width := size.x
	# The score, top left.
	_text(Vector2(5, 14), UI.format_score(roundi(_shown_score)), heading, UI.HEADING_SIZE, UI.INK)
	# The clock, in the middle: it only moves on by killing things.
	var hour := run.hour()
	var midnight: bool = hour.clock == 0 and not hour.has("past")
	var clock := run.clock_now() if not midnight else "00:00"
	var clock_color := UI.RED if midnight and int(Time.get_ticks_msec() / 500) % 2 == 0 else UI.ACCENT
	var clock_width := heading.get_string_size(clock, HORIZONTAL_ALIGNMENT_LEFT, -1, UI.HEADING_SIZE).x
	_text(Vector2(floorf((width - clock_width) * 0.5), 14), clock, heading, UI.HEADING_SIZE, clock_color)
	# The multiplier, top right, with its fuse beneath it.
	var mult := "x%d" % run.multiplier()
	var mult_width := heading.get_string_size(mult, HORIZONTAL_ALIGNMENT_LEFT, -1, UI.HEADING_SIZE).x
	var mult_color := UI.INK.lerp(UI.ACCENT, minf(_mult_pop + float(run.multiplier() - 1) / 8.0, 1.0))
	_text(Vector2(width - mult_width - 5, 14 - _mult_pop * 2.0), mult, heading, UI.HEADING_SIZE, mult_color)
	if run.combo > 0:
		var fuse := clampf(run.combo_time / run.combo_limit(), 0.0, 1.0)
		var fill := run.combo % Balance.COMBO_PER_STEP
		var bar := Rect2(width - 45, 15, 40, 2)
		draw_rect(bar, Color(0, 0, 0, 0.5))
		draw_rect(Rect2(bar.position, Vector2(bar.size.x * fuse, 1)), UI.ACCENT)
		draw_rect(Rect2(bar.position + Vector2(0, 1), Vector2(bar.size.x * fill / Balance.COMBO_PER_STEP, 1)), UI.FIRE)
	_draw_hull(run)
	_draw_perks(run)
	_draw_boss()
	if _hint_time > 0.0:
		var a := clampf(_hint_time * 2.0, 0.0, 1.0)
		_centred(size.y - 26.0, _hint, body, UI.BODY_SIZE, Color(UI.INK, a))
	if _banner_time > 0.0:
		var a := clampf(_banner_time * 2.5, 0.0, 1.0)
		var slide := pow(clampf((2.0 - _banner_time) * 6.0, 0.0, 1.0), 2.0)
		_centred(size.y * 0.5 - 8.0 + (1.0 - slide) * -14.0, _banner_big, UI.big_font(), UI.BIG_SIZE, Color(_banner_color, a))
		_centred(size.y * 0.5 + 6.0, _banner_small, body if _banner_small.length() > 18 else heading, UI.BODY_SIZE if _banner_small.length() > 18 else UI.HEADING_SIZE, Color(UI.INK, a))


func _draw_hull(run: Run) -> void:
	# Little ships, top left under the score.
	var tex := Sprites.get_tex("hull_pip")
	for i in run.max_hull:
		var at := Vector2(5 + i * 9, 18)
		var color := Color.WHITE if i < run.hull else Color(0.1, 0.1, 0.15, 0.8)
		if run.hull == 1 and i == 0 and int(Time.get_ticks_msec() / 200) % 2 == 0:
			color = UI.RED
		draw_texture(tex, at, color)


func _draw_perks(run: Run) -> void:
	var x := 5.0
	for id: String in run.perks:
		for n in run.level(id):
			var tex := Sprites.get_tex("perk_" + id)
			draw_texture(tex, Vector2(x, size.y - 12.0), Color(1, 1, 1, 0.75))
			x += 10.0


func _draw_boss() -> void:
	if world.boss == null or not world.boss.alive and world.remaining <= 0:
		return
	# All of what's left of it: its count of the hour.
	var share := clampf(float(world.remaining) / float(maxi(world.total, 1)), 0.0, 1.0)
	_boss_shown = lerpf(_boss_shown, share, 0.1)
	var bar := Rect2(floorf(size.x * 0.5) - 100, size.y - 7.0, 200, 3)
	draw_rect(bar.grow(1.0), Color.BLACK)
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * _boss_shown, bar.size.y)), UI.RED)
	var name_text: String = world.run.hour().name
	_centred(size.y - 11.0, name_text, UI.body_font(), UI.BODY_SIZE, UI.SOFT)
