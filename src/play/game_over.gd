class_name GameOver
extends Control
## The hit that ended it: CALLED IN slams down, the score counts up, and you can go again.

var _buttons: Array[SmaskButton] = []
var _run: Run
var _place := -1
var _t := 0.0
var _rolled := false


func show_for(run: Run, place: int) -> void:
	_run = run
	_place = place
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 40)
	row.position = Vector2(size.x * 0.5 - 680.0, 800.0)
	add_child(row)
	var again := SmaskButton.new("RETRY", 34)
	again.custom_minimum_size = Vector2(620, 88)
	again.pressed.connect(func() -> void: Game.main.show_screen("play", {"mode": run.mode}, 0.2))
	row.add_child(again)
	var leave := SmaskButton.new("QUIT", 34)
	leave.custom_minimum_size = Vector2(620, 88)
	leave.pressed.connect(func() -> void: Game.main.show_screen("title", {}, 0.3))
	row.add_child(leave)
	_buttons = [again, leave]
	again.focus_neighbor_right = again.get_path_to(leave)
	leave.focus_neighbor_left = leave.get_path_to(again)
	for i in 2:
		_buttons[i].index = i
		_buttons[i].alignment = HORIZONTAL_ALIGNMENT_CENTER
		_buttons[i].disabled = true
		_buttons[i].pop_in(0.9 + i * 0.08)
	UI.fx.shake(40.0)
	Audio.play("boom_big", -2.0, 0.7)
	await get_tree().create_timer(0.8).timeout
	if not is_inside_tree():
		return
	for b in _buttons:
		b.disabled = false
	again.grab_focus()


func _process(delta: float) -> void:
	_t += delta
	if _t > 0.25 and _t < 1.0 and int(_t * 30.0) != int((_t - delta) * 30.0):
		Audio.play("coin", -10.0, 0.8 + _t)
	if _t >= 1.0 and not _rolled:
		_rolled = true
		UI.fx.sparks(Vector2(size.x * 0.5, 540.0), UI.YELLOW, 30, 1200.0)
		UI.fx.shake(20.0)
		if _place == 0:
			UI.fx.flash(UI.YELLOW, 0.5)
			Audio.play("zero", -2.0)
	queue_redraw()


func _draw() -> void:
	if _run == null:
		return
	var k := UI.cubic_out(_t / 0.2)
	draw_rect(Rect2(Vector2.ZERO, size), Color(UI.INK, 0.72 * k))
	var mid := Vector2(size.x * 0.5, 280.0)
	UI.burst(self, mid, 180.0, 1500.0 * k, 22, _t * 0.25, Color(UI.RED, 0.18))
	var slam := 1.0 + (1.0 - UI.back_out(_t / 0.28, 1.3)) * 1.8
	UI.tilt(self, mid, -0.04, slam, -0.15)
	UI.centred(self, UI.title_font(), Vector2(8, 8), "GAME OVER", 150, UI.INK, 34)
	UI.centred(self, UI.title_font(), Vector2.ZERO, "GAME OVER", 150, UI.glow(UI.RED, 1.5))
	UI.straight(self)
	if _t < 0.25:
		return
	var roll := minf((_t - 0.25) / 0.75, 1.0)
	var shown := roundi(float(_run.score) * roll * roll * (3.0 - 2.0 * roll))
	var plate := Rect2(Vector2(size.x * 0.5 - 560.0, 450.0), Vector2(1120, 160))
	UI.tilt(self, Vector2.ZERO, 0.0, 1.0, 0.0)
	UI.plate(self, plate, UI.INK, UI.YELLOW, 0.2)
	UI.centred(self, UI.title_font(), plate.get_center(), UI.format_score(shown), 92, UI.YELLOW)
	var line := "%s   ///   %d KILLS   ///   %s" % [_run.clock_now(), _run.kills, UI.format_time(_run.time)]
	UI.centred(self, UI.display_font(), Vector2(size.x * 0.5, 672.0), line, 36, UI.WHITE, 12)
	if _rolled and _place >= 0:
		var text := "NEW BEST!" if _place == 0 else "RANK #%d" % (_place + 1)
		var pop := 1.0 + (1.0 - UI.back_out((_t - 1.0) / 0.25, 2.4)) * 0.7
		UI.tilt(self, Vector2(size.x * 0.5, 738.0), -0.02, pop, -0.14)
		UI.centred(self, UI.title_font(), Vector2.ZERO, text, 42, UI.hue(), 14)
		UI.straight(self)
