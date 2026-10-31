class_name OptionsPanel
extends Control
## The settings, in a column: for the title's Options and the pause menu's.

signal closed

var _rows: Array[SmaskButton] = []
var _heading_shown := true


func _init(with_heading := true) -> void:
	_heading_shown = with_heading


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	column.custom_minimum_size.x = 1180
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	center.add_child(column)
	if _heading_shown:
		column.add_child(Heading.new("OPTIONS", 72))
	_slider(column, "MUSIC", "music", 0.1)
	_slider(column, "SOUNDS", "sounds", 0.1)
	_slider(column, "SCREEN SHAKE", "shake", 0.25)
	_toggle(column, "FLASHES", "flashes")
	_toggle(column, "EASY MODE (+2 HULL, NO SCORES)", "spare_hull")
	_toggle(column, "RUMBLE", "rumble")
	if not OS.has_feature("web"):
		_toggle(column, "FULL SCREEN", "fullscreen")
	var back := SmaskButton.new("BACK", 30)
	back.pressed.connect(func() -> void: closed.emit())
	column.add_child(back)
	_rows.append(back)
	UI.link_focus(_rows)
	for i in _rows.size():
		_rows[i].index = i
		_rows[i].pop_in(i * 0.035)
	_rows[0].grab_focus()


func _slider(column: Control, text: String, key: String, step: float) -> void:
	var b := SmaskButton.new(text, 30)
	var show_value := func() -> void:
		var v: float = Game.settings[key]
		b.value = "%d%%" % roundi(v * 100.0)
		b.fill = v
	show_value.call()
	var change := func(by: float) -> void:
		Game.settings[key] = clampf(snappedf(float(Game.settings[key]) + by, 0.01), 0.0, 1.0)
		Game.apply_settings()
		Game.save()
		show_value.call()
		Audio.play("tick", -4.0, 0.7 + float(Game.settings[key]) * 0.9)
		if UI.fx:
			UI.fx.sparks(b.global_position + Vector2(b.size.x - 150.0, b.size.y * 0.5), UI.YELLOW, 5, 340.0)
	b.pressed.connect(func() -> void:
		var v: float = Game.settings[key]
		Game.settings[key] = 0.0 if v >= 0.999 else v
		change.call(step)
	)
	b.gui_input.connect(func(event: InputEvent) -> void:
		if event.is_action_pressed("ui_left"):
			change.call(-step)
			b.accept_event()
		elif event.is_action_pressed("ui_right"):
			change.call(step)
			b.accept_event()
	)
	column.add_child(b)
	_rows.append(b)


func _toggle(column: Control, text: String, key: String) -> void:
	var b := SmaskButton.new(text, 30)
	var show_value := func() -> void:
		b.value = "ON" if Game.settings[key] else "OFF"
	show_value.call()
	b.pressed.connect(func() -> void:
		Game.settings[key] = not Game.settings[key]
		Game.apply_settings()
		Game.save()
		show_value.call()
	)
	column.add_child(b)
	_rows.append(b)
