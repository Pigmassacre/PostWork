class_name PerkPick
extends Control
## Between the hours: three things, pick one.

signal picked(id: String)

var _buttons: Array[Button] = []


func offer(run: Run) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	UI.center_in(self, column)
	var title := UI.label("IT'S %s. TAKE SOMETHING." % Hours.clock_text(int(Hours.at(run.hour_index + 1).clock)), UI.ACCENT, true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var choices := Perks.offer(run.perks, 3, run.rng)
	for id: String in choices:
		var def: Dictionary = Perks.ALL[id]
		var b := UI.button("%s\n%s" % [def.name, def.text])
		b.icon = Sprites.get_tex("perk_" + id)
		b.expand_icon = false
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_constant_override("h_separation", 6)
		b.add_theme_constant_override("line_spacing", 2)
		b.custom_minimum_size = Vector2(260, 26)
		b.pressed.connect(func() -> void: _choose(id))
		column.add_child(b)
		_buttons.append(b)
	if _buttons.is_empty():
		_choose.call_deferred("")
		return
	UI.link_focus(_buttons)
	# So a held SMASK doesn't choose by accident.
	for b in _buttons:
		b.disabled = true
	await get_tree().create_timer(0.45).timeout
	if not is_inside_tree():
		return
	for b in _buttons:
		b.disabled = false
	_buttons[0].grab_focus()
	if Game.autoplay:
		_buttons[run.rng.randi() % _buttons.size()].pressed.emit()


func _choose(id: String) -> void:
	Audio.play("perk", -2.0)
	picked.emit(id)
	queue_free()
