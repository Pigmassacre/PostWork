class_name PauseMenu
extends Control
## Esc: the evening waits, in a great freeze-frame behind a slab.

## The standing under the buttons waits for them to land first.
const STANDING_DELAY := 0.22

var _resume: SmaskButton
var _buttons: Array[SmaskButton] = []
var _options_panel: Control
var _content: Control
var _t := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_content = Control.new()
	_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_content)
	var column := VBoxContainer.new()
	column.position = Vector2(90, 420)
	column.custom_minimum_size.x = 620
	column.add_theme_constant_override("separation", 10)
	_content.add_child(column)
	_resume = SmaskButton.new("RESUME", 38)
	_resume.pressed.connect(close)
	column.add_child(_resume)
	var options := SmaskButton.new("OPTIONS", 38)
	options.pressed.connect(_open_options)
	column.add_child(options)
	var quit := SmaskButton.new("QUIT", 38)
	quit.pressed.connect(_give_up)
	column.add_child(quit)
	_buttons = [_resume, options, quit]
	UI.link_focus(_buttons)
	for i in _buttons.size():
		_buttons[i].index = i
		_buttons[i].indent = -i * 18.0


func open() -> void:
	get_tree().paused = true
	visible = true
	_t = 0.0
	for i in _buttons.size():
		_buttons[i].pop_in(0.05 + i * 0.05)
	_resume.grab_focus()
	Audio.muffle(0.75)
	Audio.set_engine(0.0, 1.0)
	Audio.play("tick", -4.0, 0.7)
	UI.fx.shake(5.0)


func close() -> void:
	if _options_panel:
		_options_panel.queue_free()
		_options_panel = null
		_content.visible = true
	visible = false
	get_tree().paused = false
	Audio.muffle(0.0)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var k := UI.cubic_out(_t / 0.2)
	draw_rect(Rect2(Vector2.ZERO, size), Color(UI.INK, 0.5 * k))
	var h := size.y
	if _options_panel:
		draw_rect(Rect2(Vector2.ZERO, size), Color(UI.INK, 0.5))
		return
	var top := 1060.0 * k
	var bottom := 730.0 * k
	for band: Array in [[44.0, UI.glow(UI.PINK, 1.25)], [22.0, UI.YELLOW]]:
		var w: float = band[0]
		UI.fill(self, PackedVector2Array([Vector2(-10, -10), Vector2(top + w, -10), Vector2(bottom + w, h + 10), Vector2(-10, h + 10)]), band[1])
	UI.fill(self, PackedVector2Array([Vector2(-10, -10), Vector2(top, -10), Vector2(bottom, h + 10), Vector2(-10, h + 10)]), UI.INK)
	var slam := 1.0 + (1.0 - UI.back_out(_t / 0.26, 1.4)) * 1.4
	UI.tilt(self, Vector2(80, 310), -0.05, slam, -0.16)
	draw_string(UI.title_font(), Vector2(7, 7), "PAUSED", HORIZONTAL_ALIGNMENT_LEFT, -1, 130, UI.PINK)
	draw_string(UI.title_font(), Vector2.ZERO, "PAUSED", HORIZONTAL_ALIGNMENT_LEFT, -1, 130, UI.YELLOW)
	UI.straight(self)
	if Game.run:
		_draw_standing(Game.run)


## Where the evening's got to, under the buttons: a stripe wipes in, the hour
## slams down on it, and the score counts up to what it is.
func _draw_standing(run: Run) -> void:
	var t := _t - STANDING_DELAY
	if t <= 0.0:
		return
	var wipe := UI.cubic_out(t / 0.18)
	var at := Vector2(60, 800)
	# The stripe, along the slant of the buttons above.
	UI.slab(self, Rect2(at + Vector2(-80, -8), Vector2(560 * wipe, 6)), UI.PINK, 0.8, 2.0)
	var hour_in := UI.back_out((t - 0.06) / 0.3, 1.6)
	if hour_in > 0.0:
		UI.tilt(self, at + Vector2(-60.0 * (1.0 - hour_in), 46), -0.03, 0.6 + 0.4 * hour_in, -0.16)
		var clock := "%s   %s" % [run.clock_now(), run.hour().name]
		UI.outlined(self, UI.display_font(), Vector2.ZERO, clock, 32, Color(UI.CYAN, clampf(hour_in * 2.0, 0.0, 1.0)), 10)
		UI.straight(self)
	var score_t := clampf((t - 0.14) / 0.45, 0.0, 1.0)
	if score_t > 0.0:
		var slam := 1.0 + (1.0 - UI.back_out(score_t * 1.6, 2.2)) * 0.6
		var shown := roundi(run.score * UI.cubic_out(score_t))
		UI.tilt(self, at + Vector2(-14, 124), -0.03, slam, -0.16)
		UI.outlined(self, UI.title_font(), Vector2.ZERO, UI.format_score(shown), 58, UI.WHITE, 16)
		var w := UI.text_width(UI.title_font(), UI.format_score(shown), 58)
		var mult_in := UI.back_out((score_t - 0.7) / 0.3, 2.4)
		if mult_in > 0.0:
			var mult := "X%d" % run.multiplier()
			UI.tilt(self, at + Vector2(w + 20.0, 124), -0.08, mult_in, -0.16)
			UI.outlined(self, UI.title_font(), Vector2.ZERO, mult, 44, UI.YELLOW, 14)
		UI.straight(self)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if _options_panel:
			_close_options()
		else:
			close()


func _open_options() -> void:
	_content.visible = false
	_options_panel = OptionsPanel.new()
	_options_panel.closed.connect(_close_options)
	add_child(_options_panel)


func _close_options() -> void:
	if _options_panel:
		_options_panel.queue_free()
		_options_panel = null
	_content.visible = true
	_resume.grab_focus()


func _give_up() -> void:
	Game.record_run(Game.run, false)
	get_tree().paused = false
	Audio.muffle(0.0)
	Game.main.show_screen("title", {}, 0.3)
