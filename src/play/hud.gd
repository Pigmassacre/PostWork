class_name Hud
extends Control
## The HUD, in full resolution over the game's pixels: the score, the clock, the
## multiplier, the hull, the count as a hologram over the floor, a gauge round the
## ship for how long it's safe, words flying off what dies, and banners that slam.

const BANNER_TIME := 1.9

var world: World
var view: GameView
var _banner_big := ""
var _banner_small := ""
var _banner_color := UI.WHITE
var _banner_time := 0.0
var _hint := ""
var _hint_time := 0.0
var _shown_score := 0.0
var _score_pop := 0.0
var _mult_pop := 0.0
var _last_mult := 1
var _boss_shown := 1.0
var _boss_trail := 1.0
var _last_count := -1
var _count_pop := 0.0
var _last_minutes := 0
var _clock_pop := 0.0
var _last_hull := -1
var _hull_hit := 0.0
var _was_ready := true
var _ready_ping := 0.0
var _chips: PerkChips
var _time := 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chips = PerkChips.new()
	_chips.hud = self
	add_child(_chips)


func banner(big: String, small: String, color: Color) -> void:
	_banner_big = big
	_banner_small = small
	_banner_color = color
	_banner_time = BANNER_TIME
	UI.fx.shake(26.0)


func clear_banner() -> void:
	_banner_time = 0.0


func hint(text: String, seconds := 6.0) -> void:
	_hint = text
	_hint_time = seconds


func _process(delta: float) -> void:
	_time += delta
	_banner_time = maxf(_banner_time - delta, 0.0)
	_hint_time = maxf(_hint_time - delta, 0.0)
	_mult_pop = maxf(_mult_pop - delta * 5.0, 0.0)
	_score_pop = maxf(_score_pop - delta * 7.0, 0.0)
	_count_pop = maxf(_count_pop - delta * 5.0, 0.0)
	_clock_pop = maxf(_clock_pop - delta * 5.0, 0.0)
	_hull_hit = maxf(_hull_hit - delta * 2.5, 0.0)
	_ready_ping = maxf(_ready_ping - delta * 3.0, 0.0)
	var run := world.run
	var before := _shown_score
	_shown_score = move_toward(_shown_score, float(run.score), maxf(float(run.score) - _shown_score, 80.0) * delta * 8.0)
	if roundi(_shown_score) != roundi(before):
		_score_pop = maxf(_score_pop, 0.5)
	if run.multiplier() != _last_mult:
		if run.multiplier() > _last_mult:
			_mult_pop = 1.0
			UI.fx.sparks(Vector2(size.x - 130.0, 56.0), UI.YELLOW, 8 + run.multiplier(), 560.0)
		_last_mult = run.multiplier()
	if world.remaining != _last_count:
		if world.remaining < _last_count:
			_count_pop = 1.0
		_last_count = world.remaining
	if run.minutes != _last_minutes:
		_last_minutes = run.minutes
		_clock_pop = 1.0
	if _last_hull >= 0 and run.hull < _last_hull:
		_hull_hit = 1.0
		UI.fx.sparks(Vector2(40.0 + run.hull * 44.0, 112.0), UI.RED, 18, 800.0)
	_last_hull = run.hull
	var ready_now: bool = world.ship.cooldown <= 0.0
	if ready_now and not _was_ready:
		_ready_ping = 1.0
	_was_ready = ready_now
	position = UI.fx.offset + world.fx.offset * view.ui_scale * 0.5
	queue_redraw()


func _draw() -> void:
	_draw_count()
	_draw_words()
	_draw_ship_gauge()
	_draw_score()
	_draw_clock()
	_draw_multiplier()
	_draw_boss()
	_draw_hurt_edge()
	_draw_hint()
	_draw_banner()


## The hour's count, as a great hollow number hanging over the floor.
func _draw_count() -> void:
	var run_over := world.phase == World.Phase.OVER
	if run_over:
		return
	var text := str(maxi(world.remaining, 0))
	var font := UI.title_font()
	var font_size := 300
	var mid := view.world_to_ui(Vector2.ZERO)
	var k := 1.0 + _count_pop * 0.1
	var color := Color(UI.hue(0.5, 0.5), 0.13 + _count_pop * 0.3)
	if world.phase == World.Phase.CLEARED:
		color = Color(UI.YELLOW, 0.55)
	UI.tilt(self, mid, 0.0, k, -0.1)
	var w := UI.text_width(font, text, font_size)
	draw_string_outline(font, Vector2(-w * 0.5, font_size * 0.36), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 7, color)
	UI.straight(self)


func _draw_words() -> void:
	var font := UI.title_font()
	for w: Fx.Word in world.fx.words:
		var t := 1.0 - w.life / w.total
		var a := clampf(w.life / w.total * 3.0, 0.0, 1.0)
		var k := 0.5 + UI.back_out(t * 6.0, 2.4) * 0.5
		var font_size := 26 if w.text.is_valid_int() else 36
		var at := view.world_to_ui(w.pos)
		UI.tilt(self, at, -0.06, k, -0.16)
		UI.centred(self, font, Vector2.ZERO, w.text, font_size, Color(w.color, a), 12, Color(UI.INK, a))
	UI.straight(self)


## Round the ship: how long it's safe, draining; how the SMASK's charging; when it's back.
func _draw_ship_gauge() -> void:
	var ship := world.ship
	if ship.state == Ship.State.DEAD:
		return
	var at := view.world_to_ui(ship.pos)
	var radius := 58.0
	var start := -PI * 0.5
	var safe := ship.safety()
	if safe > 0.0:
		var color := UI.YELLOW if ship.safe_from_smask else UI.BLUE
		# The last of it's red and throbbing: get ready.
		if safe < 0.34:
			color = UI.RED if int(_time * 28.0) % 2 == 0 else UI.WHITE
		draw_arc(at, radius, 0.0, TAU, 64, Color(UI.INK, 0.45), 14.0, true)
		draw_arc(at, radius, start, start + TAU * safe, 64, UI.INK, 16.0, true)
		draw_arc(at, radius, start, start + TAU * safe, 64, color, 10.0, true)
	if ship.state == Ship.State.CHARGING:
		var full := ship.charge >= 1.0
		var color := UI.YELLOW if full else UI.WHITE
		var wide := 12.0 + (6.0 * sin(_time * 40.0) if full else 0.0)
		draw_arc(at, radius, start, start + TAU * ship.charge, 64, UI.INK, wide + 6.0, true)
		draw_arc(at, radius, start, start + TAU * ship.charge, 64, color, wide, true)
		if full:
			UI.burst(self, at, radius + 14.0, radius + 40.0, 12, _time * 3.0, UI.YELLOW)
	elif ship.cooldown > 0.0 and safe <= 0.0:
		var back := 1.0 - ship.cooldown / Balance.SMASK_COOLDOWN
		draw_arc(at, radius - 8.0, start, start + TAU * back, 48, Color(UI.WHITE, 0.55), 4.0, true)
	if _ready_ping > 0.0:
		draw_arc(at, radius + (1.0 - _ready_ping) * 40.0, 0.0, TAU, 48, Color(UI.CYAN, _ready_ping), 3.0 + _ready_ping * 6.0, true)


func _draw_score() -> void:
	var run := world.run
	UI.tilt(self, Vector2(26, 62), -0.02, 1.0 + _score_pop * 0.05, -0.16)
	UI.outlined(self, UI.title_font(), Vector2.ZERO, UI.format_score(roundi(_shown_score)), 54, UI.WHITE, 16)
	UI.straight(self)
	# The hull: slanted cells, the lost ones hollow.
	for i in run.max_hull:
		var cell := Rect2(Vector2(32.0 + i * 44.0, 78.0), Vector2(38, 18))
		var color := UI.CYAN
		if run.hull == 1:
			color = UI.RED if int(_time * 8.0) % 2 == 0 else UI.WHITE
		if i < run.hull:
			UI.slab(self, cell.grow(3.0), UI.INK, 0.8)
			UI.slab(self, cell, color, 0.8)
		else:
			UI.slab(self, cell.grow(3.0), UI.INK, 0.8)
			UI.slab(self, cell.grow(-2.0), Color(UI.RED, 0.25 + _hull_hit * 0.75), 0.8)


func _draw_clock() -> void:
	var run := world.run
	var hour := run.hour()
	var midnight: bool = hour.clock == 0 and not hour.has("past")
	var text := "00:00" if midnight else run.clock_now()
	var mid := Vector2(size.x * 0.5, 50.0)
	var font := UI.title_font()
	var w := 300.0
	var strobe: bool = midnight and int(_time * 4.0) % 2 == 0
	UI.tilt(self, mid, 0.0, 1.0 + _clock_pop * 0.06, 0.0)
	UI.plate(self, Rect2(-w * 0.5, -42, w, 76), UI.RED if strobe else UI.INK, UI.PINK if midnight else UI.hue(), 0.5)
	var color := UI.WHITE if strobe else (UI.RED if midnight else UI.YELLOW)
	UI.tilt(self, mid, 0.0, 1.0 + _clock_pop * 0.06, -0.14)
	UI.centred(self, font, Vector2(0, -6), text, 50, color)
	UI.straight(self)
	# How far through the hour it's got.
	if not midnight:
		var bar := Rect2(mid + Vector2(-w * 0.5 + 8.0, 40.0), Vector2(w - 16.0, 9.0))
		UI.slab(self, bar, UI.INK, 0.8)
		UI.slab(self, Rect2(bar.position, Vector2(bar.size.x * run.minutes / 59.0, bar.size.y)), UI.YELLOW, 0.8)


func _draw_multiplier() -> void:
	var run := world.run
	var mult := run.multiplier()
	var text := "X%d" % mult
	var font_size := 50 + mini(mult, 16) * 3
	var heat := float(mult - 1) / 15.0
	var color := UI.WHITE.lerp(UI.YELLOW, minf(heat * 3.0, 1.0)).lerp(UI.PINK, maxf(heat * 2.0 - 1.0, 0.0))
	var at := Vector2(size.x - 28.0, 66.0)
	var shake := Vector2(sin(_time * 61.0), cos(_time * 47.0)) * heat * 3.0
	if mult >= 4:
		UI.burst(self, at + Vector2(-50, -26), 44.0, 80.0 + heat * 40.0 + _mult_pop * 30.0, 12, _time * 2.0, Color(UI.hue(0.5), 0.6))
	UI.tilt(self, at + shake, -0.05, 1.0 + _mult_pop * 0.5, -0.16)
	var w := UI.text_width(UI.title_font(), text, font_size)
	UI.outlined(self, UI.title_font(), Vector2(-w, 0), text, font_size, color, 18)
	UI.straight(self)
	if run.combo > 0:
		var fuse := clampf(run.combo_time / run.combo_limit(), 0.0, 1.0)
		var fill := float(run.combo % Balance.COMBO_PER_STEP) / Balance.COMBO_PER_STEP
		var bar := Rect2(Vector2(size.x - 256.0, 82.0), Vector2(226, 14))
		UI.slab(self, bar.grow(3.0), UI.INK, 0.8)
		UI.slab(self, Rect2(bar.position, Vector2(bar.size.x * fuse, 7)), UI.YELLOW, 0.8)
		UI.slab(self, Rect2(bar.position + Vector2(0, 7), Vector2(bar.size.x * fill, 7)), UI.ORANGE, 0.8)


func _draw_boss() -> void:
	if world.boss == null or world.remaining <= 0 or world.phase == World.Phase.WAITING:
		return
	var share := clampf(float(world.remaining) / float(maxi(world.total, 1)), 0.0, 1.0)
	_boss_shown = lerpf(_boss_shown, share, 0.2)
	_boss_trail = lerpf(_boss_trail, share, 0.03)
	var bar := Rect2(Vector2(size.x * 0.5 - 480.0, size.y - 42.0), Vector2(960, 22))
	UI.slab(self, bar.grow(5.0), UI.INK, 0.8)
	UI.slab(self, Rect2(bar.position, Vector2(bar.size.x * _boss_trail, bar.size.y)), UI.WHITE, 0.8)
	UI.slab(self, Rect2(bar.position, Vector2(bar.size.x * _boss_shown, bar.size.y)), UI.PINK, 0.8)
	var name_text: String = world.run.hour().name
	UI.tilt(self, Vector2(size.x * 0.5, size.y - 54.0), -0.012, 1.0, -0.16)
	UI.centred(self, UI.display_font(), Vector2.ZERO, name_text, 30, UI.WHITE, 12)
	UI.straight(self)


func _draw_hurt_edge() -> void:
	if _hull_hit <= 0.0:
		return
	var a := _hull_hit * 0.65
	var w := 90.0 * _hull_hit
	draw_rect(Rect2(0, 0, size.x, w), Color(UI.RED, a))
	draw_rect(Rect2(0, size.y - w, size.x, w), Color(UI.RED, a))
	draw_rect(Rect2(0, 0, w, size.y), Color(UI.RED, a))
	draw_rect(Rect2(size.x - w, 0, w, size.y), Color(UI.RED, a))


func _draw_hint() -> void:
	if _hint_time <= 0.0:
		return
	var font := UI.body_font()
	var font_size := 34
	var w := UI.text_width(font, _hint, font_size)
	var enter := UI.back_out((7.0 - _hint_time) * 4.0)
	var leave := clampf(_hint_time * 5.0, 0.0, 1.0)
	var at := Vector2(size.x * 0.5, size.y - 128.0 + (1.0 - enter) * 300.0 + (1.0 - leave) * 300.0)
	UI.tilt(self, at, -0.015, 1.0, 0.0)
	UI.plate(self, Rect2(-w * 0.5 - 40.0, -36, w + 80.0, 72), UI.INK, UI.YELLOW, 0.3)
	UI.centred(self, font, Vector2.ZERO, _hint, font_size, UI.WHITE)
	UI.straight(self)


## A band slamming across the screen, with a sunburst, and an hour or a ZERO on it.
func _draw_banner() -> void:
	if _banner_time <= 0.0:
		return
	var t := BANNER_TIME - _banner_time
	var mid := size * 0.5 + Vector2(0, -20)
	var enter := UI.cubic_out(t / 0.16)
	var leave := UI.cubic_out((0.28 - _banner_time) / 0.28)
	var slide := (1.0 - enter) * -2600.0 + maxf(leave, 0.0) * 2600.0
	var zero: bool = _banner_big == "ZERO"
	var band_color := UI.YELLOW if zero else UI.INK
	var ink_color := UI.INK if zero else _banner_color
	var a := 1.0 - maxf(leave, 0.0)
	UI.burst(self, mid, 160.0, 1500.0 * enter, 22, t * 0.7, Color(UI.hue(0.5) if not zero else UI.YELLOW, 0.22 * a))
	UI.tilt(self, mid + Vector2(slide, 0), -0.05, 1.0, 0.0)
	draw_rect(Rect2(-1800, -170, 3600, 12), UI.PINK)
	draw_rect(Rect2(-1800, 126, 3600, 12), UI.hue())
	draw_rect(Rect2(-1800, -158, 3600, 284), band_color)
	var slam := 1.0 + (1.0 - UI.back_out(t / 0.24, 1.4)) * 1.7
	UI.tilt(self, mid + Vector2(slide * 1.3, -50.0), -0.05, slam, -0.16)
	var font_size := 150
	if not zero:
		UI.centred(self, UI.title_font(), Vector2(7, 7), _banner_big, font_size, UI.PINK)
	UI.centred(self, UI.title_font(), Vector2.ZERO, _banner_big, font_size, ink_color)
	UI.tilt(self, mid + Vector2(slide * 0.8, 74.0), -0.05, 1.0, -0.1)
	var long := _banner_small.length() > 24
	UI.centred(self, UI.display_font(), Vector2.ZERO, _banner_small, 30 if long else 54, UI.INK if zero else UI.WHITE)
	UI.straight(self)


## What's been taken, along the bottom: the original pixel-style icons, blown up.
class PerkChips extends Control:
	var hud: Hud

	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		var x := 26.0
		var y := size.y - 56.0
		var run := hud.world.run
		for id: String in run.perks:
			for n in run.level(id):
				UI.slab(self, Rect2(x, y, 44, 44), Color(UI.INK, 0.8), 0.25)
				var tex := Sprites.get_tex("perk_" + id)
				var drawn := tex.get_size() * 3.0
				draw_texture_rect(tex, Rect2(Vector2(x + 22.0, y + 22.0) - drawn * 0.5, drawn), false)
				x += 50.0
