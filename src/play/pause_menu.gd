class_name PauseMenu
extends Control
## Esc: the evening waits, in a great freeze-frame behind a slab.

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
	var run := Game.run
	if run:
		var y := 700.0
		UI.outlined(self, UI.display_font(), Vector2(90, y), run.hour().name, 32, UI.CYAN)
		UI.outlined(self, UI.title_font(), Vector2(90, y + 74), "%s   X%d" % [UI.format_score(run.score), run.multiplier()], 50, UI.WHITE)


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
