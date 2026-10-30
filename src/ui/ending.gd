extends Node
## 00:00. The clock's gone, and it's tomorrow.

var _shown := 0.0
var _lines: Array[Label] = []
var _ready_to_leave := false
var _run: Run


func open(args: Dictionary) -> void:
	_run = args.run
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	var ui := Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(ui)
	var bg := ColorRect.new()
	bg.color = Color("0a0a14")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(bg)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	UI.center_in(ui, column)
	var zero := Label.new()
	zero.text = "00:00"
	zero.add_theme_font_override("font", UI.big_font())
	zero.add_theme_font_size_override("font_size", UI.BIG_SIZE)
	zero.add_theme_color_override("font_color", UI.ACCENT)
	zero.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(zero)
	_lines.append(zero)
	for text: String in [
		"The evening's yours. All of it. You smasked it to zero.",
		"You should really get some sleep.",
		"Work's in eight hours.",
	]:
		var l := UI.label(text, UI.SOFT)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		column.add_child(l)
		_lines.append(l)
	var score := UI.label("%s   IN %s" % [UI.format_score(_run.score), UI.format_time(_run.time)], UI.ACCENT)
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(score)
	_lines.append(score)
	var unlock := UI.label("THE GRAVEYARD SHIFT IS OPEN: IT GOES ON PAST MIDNIGHT, UNTIL IT GETS YOU.", UI.GREEN)
	unlock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(unlock)
	_lines.append(unlock)
	for l in _lines:
		l.modulate.a = 0.0
	Audio.heat = 0.0
	Audio.play_music("ending", 2.0)


func _process(delta: float) -> void:
	_shown += delta
	for i in _lines.size():
		_lines[i].modulate.a = clampf((_shown - 0.5 - i * 1.4) * 1.5, 0.0, 1.0)
	_ready_to_leave = _shown > 1.5 + _lines.size() * 1.4


func _unhandled_input(event: InputEvent) -> void:
	if _ready_to_leave and (event.is_action_pressed("ui_accept") or event.is_action_pressed("pause") or event is InputEventMouseButton and event.pressed):
		get_viewport().set_input_as_handled()
		Game.main.show_screen("title", {}, 0.5)
