class_name GameOver
extends Control
## The hit that ended it.

var _buttons: Array[Button] = []


func show_for(run: Run, place: int) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 2)
	UI.center_in(self, column)
	var title := UI.label("CALLED IN AT " + run.clock_now(), UI.RED, true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var score := UI.label(UI.format_score(run.score), UI.INK, true)
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(score)
	var detail := "%d smasked in %s" % [run.kills, UI.format_time(run.time)]
	if place == 0:
		detail += ". YOUR BEST EVENING YET."
	elif place > 0:
		detail += ". NUMBER %d ON THE LIST." % (place + 1)
	var line := UI.label(detail, UI.ACCENT if place == 0 else UI.SOFT)
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(line)
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 6)
	column.add_child(gap)
	var again := UI.button("Clock out again")
	again.pressed.connect(func() -> void: Game.main.show_screen("play", {"mode": run.mode}, 0.2))
	column.add_child(again)
	var leave := UI.button("Call it a night")
	leave.pressed.connect(func() -> void: Game.main.show_screen("title", {}, 0.3))
	column.add_child(leave)
	_buttons = [again, leave]
	UI.link_focus(_buttons)
	for b in _buttons:
		b.alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.disabled = true
	await get_tree().create_timer(0.6).timeout
	if not is_inside_tree():
		return
	for b in _buttons:
		b.disabled = false
	again.grab_focus()
