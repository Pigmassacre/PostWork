class_name PerkPick
extends Control
## Between the hours: three cards slam down. Pick one and the others are thrown off.

signal picked(id: String)

var _cards: Array[PerkCard] = []
var _next_clock := ""
var _t := 0.0
var _done := false


func offer(run: Run) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_next_clock = Hours.clock_text(int(Hours.at(run.hour_index + 1).clock))
	var choices := Perks.offer(run.perks, 3, run.rng)
	if choices.is_empty():
		_choose.call_deferred("")
		return
	var count := choices.size()
	for i in count:
		var id: String = choices[i]
		var card := PerkCard.new()
		card.id = id
		card.taken = run.level(id)
		card.size = PerkCard.SIZE
		card.delay = 0.08 + i * 0.09
		card.tilt = (float(i) - (count - 1) * 0.5) * 0.035
		card.pressed.connect(func() -> void: _choose(id))
		add_child(card)
		_cards.append(card)
	_lay_out()
	for i in count:
		var c := _cards[i]
		c.focus_neighbor_left = c.get_path_to(_cards[wrapi(i - 1, 0, count)])
		c.focus_neighbor_right = c.get_path_to(_cards[wrapi(i + 1, 0, count)])
		c.focus_neighbor_top = c.get_path()
		c.focus_neighbor_bottom = c.get_path()
		# So a held SMASK doesn't choose by accident.
		c.disabled = true
	Audio.play("warning", -16.0, 1.4)
	await get_tree().create_timer(0.5).timeout
	if not is_inside_tree():
		return
	for c in _cards:
		c.disabled = false
	_cards[0].grab_focus()
	if Game.autoplay:
		_choose(_cards[run.rng.randi() % _cards.size()].id)


func _lay_out() -> void:
	var count := _cards.size()
	var gap := 56.0
	var whole := count * PerkCard.SIZE.x + (count - 1) * gap
	for i in count:
		_cards[i].position = Vector2((size.x - whole) * 0.5 + i * (PerkCard.SIZE.x + gap), size.y * 0.5 - PerkCard.SIZE.y * 0.5 + 76.0)


func _process(delta: float) -> void:
	_t += delta
	_lay_out()
	queue_redraw()


func _draw() -> void:
	var k := UI.cubic_out(_t / 0.2)
	if _done:
		k = 1.0
	draw_rect(Rect2(Vector2.ZERO, size), Color(UI.INK, 0.72 * k))
	var mid := Vector2(size.x * 0.5, 130.0)
	UI.burst(self, mid, 90.0, 1200.0 * k, 24, _t * 0.2, Color(UI.hue(0.5), 0.13))
	UI.tilt(self, mid + Vector2((1.0 - k) * -2000.0, 0), -0.02, 1.0 + (1.0 - UI.back_out(_t / 0.3)) * 1.2, 0.0)
	UI.plate(self, Rect2(-500, -68, 1000, 136), UI.INK, UI.glow(UI.YELLOW, 1.5), 0.35)
	UI.tilt(self, mid + Vector2((1.0 - k) * -2000.0, 0), -0.02, 1.0 + (1.0 - UI.back_out(_t / 0.3)) * 1.2, -0.14)
	UI.centred(self, UI.title_font(), Vector2(5, 5), "%s  PICK ONE" % _next_clock, 72, UI.PINK)
	UI.centred(self, UI.title_font(), Vector2.ZERO, "%s  PICK ONE" % _next_clock, 72, UI.YELLOW)
	UI.straight(self)


func _choose(id: String) -> void:
	if _done:
		return
	_done = true
	Audio.play("perk", -2.0)
	UI.fx.flash(UI.WHITE, 0.5)
	UI.fx.shake(30.0)
	for c in _cards:
		if c.id == id:
			c.chosen()
		else:
			c.throw_off()
	picked.emit(id)
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.3).set_delay(0.12)
	t.tween_callback(queue_free)


class PerkCard extends Button:
	const SIZE := Vector2(480, 620)

	var id := ""
	var taken := 0
	var delay := 0.0
	var tilt := 0.0
	var _in := 0.0
	var _lit := 0.0
	var _pop := 0.0
	var _pop_vel := 0.0
	var _gone := 0.0
	var _throw := Vector2.ZERO
	var _time := 0.0

	func _ready() -> void:
		process_mode = Node.PROCESS_MODE_ALWAYS
		focus_mode = Control.FOCUS_ALL
		var empty := StyleBoxEmpty.new()
		for state in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
			add_theme_stylebox_override(state, empty)
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseMotion and event.relative.length() > 0.5 and not disabled and not has_focus():
				grab_focus()
		)
		focus_entered.connect(func() -> void:
			z_index = 3
			_pop_vel = 8.0
			Audio.play("tick", -6.0, 1.1)
			UI.fx.sparks(global_position + size * 0.5, _color(), 12, 700.0)
		)
		focus_exited.connect(func() -> void: z_index = 0)

	func _color() -> Color:
		return Color(Perks.ALL[id].color)

	func chosen() -> void:
		_throw = Vector2(0, -2200)
		_gone = 0.001
		UI.fx.sparks(global_position + size * 0.5, _color(), 40, 1500.0)
		UI.fx.ring(global_position + size * 0.5, 700.0, _color(), 0.5)

	func throw_off() -> void:
		_throw = Vector2(randf_range(-900.0, 900.0), 2400.0)
		_gone = 0.001

	func _process(delta: float) -> void:
		_time += delta
		delay -= delta
		if delay <= 0.0 and _in < 1.0:
			_in = minf(_in + delta / 0.28, 1.0)
			if _in >= 1.0:
				UI.fx.shake(10.0)
				Audio.play("hit", -7.0, 0.8)
		_lit = move_toward(_lit, 1.0 if has_focus() else 0.0, delta * 9.0)
		_pop_vel += (-_pop * 240.0 - _pop_vel * 15.0) * delta
		_pop += _pop_vel * delta
		if _gone > 0.0:
			_gone += delta
		queue_redraw()

	func _draw() -> void:
		if _in <= 0.0:
			return
		var mid := size * 0.5
		var lift := _lit * -34.0
		var at := mid + Vector2(0, (1.0 - UI.back_out(_in, 1.4)) * 1300.0 + lift) + _throw * _gone * _gone * 4.0
		var rot := tilt * (1.0 - _lit) + (1.0 - _in) * tilt * 8.0 + _gone * 5.0 * signf(_throw.x + 0.01)
		var k := 1.0 + _lit * 0.07 + _pop * 0.4
		draw_set_transform_matrix(Transform2D(rot, Vector2(k, k), 0.0, at))
		var r := Rect2(-mid, size)
		var color := _color()
		if _lit > 0.0:
			UI.burst(self, Vector2.ZERO, 240.0, 460.0 + 70.0 * _lit, 16, _time * 0.8, Color(UI.glow(UI.YELLOW, 1.8), 0.55 * _lit))
		UI.plate(self, r, UI.INK.lerp(UI.YELLOW, _lit), UI.glow(color.lerp(UI.WHITE, _lit), 1.0 + _lit * 1.2), 0.06)
		var ink := UI.WHITE.lerp(UI.INK, _lit)
		# The icon, huge, in its own big pixels.
		var header := Rect2(r.position + Vector2(14, 14), Vector2(size.x - 28.0, 250))
		UI.slab(self, header, color.lerp(UI.INK, 0.15 + 0.1 * _lit), 0.06)
		var tex := Sprites.get_tex("perk_" + id)
		var drawn := tex.get_size() * 22.0
		var bob := sin(_time * 3.0) * 6.0 * _lit
		draw_texture_rect(tex, Rect2(header.get_center() - drawn * 0.5 + Vector2(6, 8 + bob), drawn), false, Color(0, 0, 0, 0.45))
		draw_texture_rect(tex, Rect2(header.get_center() - drawn * 0.5 + Vector2(0, bob), drawn), false)
		var def: Dictionary = Perks.ALL[id]
		var y := r.position.y + 320.0
		var name_text: String = def.name
		var name_size := 40
		while UI.text_width(UI.display_font(), name_text, name_size) > size.x - 60.0 and name_size > 22:
			name_size -= 2
		UI.outlined(self, UI.display_font(), Vector2(r.position.x + 30.0, y), name_text, name_size, ink)
		UI.paragraph(self, Vector2(r.position.x + 30.0, y + 58.0), def.text, size.x - 60.0, 40, ink)
		# How many of it you've got, and could have.
		var most: int = def.most
		for i in most:
			var pip := Rect2(r.position + Vector2(32.0 + i * 54.0, size.y - 50.0), Vector2(44, 18))
			UI.slab(self, pip, ink if i <= taken else Color(ink, 0.2), 0.8)
		draw_set_transform_matrix(Transform2D.IDENTITY)
