extends Node
## The title: the game playing itself behind the logo the original game had.

var _world: World
var _buttons: Array[Button] = []


func _ready() -> void:
	var run := Run.new()
	run.start(Run.EVENING, randi(), randi() % 2 + 3)
	_world = World.new()
	_world.setup(run, true)
	add_child(_world)
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	var ui := Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(ui)
	var dim := ColorRect.new()
	dim.color = Color(UI.PANEL, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(dim)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 1)
	UI.center_in(ui, column)
	column.add_child(Logo.new())
	var line := UI.label("Clock out. Smask everything. Count it down to zero.", UI.SOFT)
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(line)
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 6)
	column.add_child(gap)
	_add(column, "Clock out", func() -> void: Game.main.show_screen("play", {"mode": Run.EVENING}, 0.25))
	if Game.wins > 0:
		_add(column, "Graveyard shift", func() -> void: Game.main.show_screen("play", {"mode": Run.GRAVEYARD}, 0.25))
	_add(column, "How it's played", func() -> void: Game.main.show_screen("help", {}, 0.2))
	_add(column, "Best evenings", func() -> void: Game.main.show_screen("scores", {}, 0.2))
	_add(column, "Options", func() -> void: Game.main.show_screen("options", {}, 0.2))
	_add(column, "Credits", func() -> void: Game.main.show_screen("credits", {}, 0.2))
	if not OS.has_feature("web"):
		_add(column, "Quit", func() -> void: get_tree().quit())
	UI.link_focus(_buttons)
	_buttons[0].grab_focus()
	var version := UI.label(Game.version_text(), UI.FAINT)
	version.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	version.offset_left = -120
	version.offset_top = -11
	version.offset_right = -3
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ui.add_child(version)
	if Game.best_score() > 0:
		var best := UI.label("BEST " + UI.format_score(Game.best_score()), UI.ACCENT)
		best.position = Vector2(4, 3)
		ui.add_child(best)
	Audio.heat = 0.4
	Audio.play_music("title", 1.0)


func _add(column: Control, text: String, on_press: Callable) -> void:
	var b := UI.button(text)
	b.alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.custom_minimum_size.x = 120
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.pressed.connect(on_press)
	column.add_child(b)
	_buttons.append(b)
