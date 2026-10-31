extends Node
## The title: the game itself, in its pixels, playing away behind a great slanted
## slab of the opposite of pixels.

var _world: World
var _buttons: Array[SmaskButton] = []
var _shaker: Control
var _ticker: Ticker


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var run := Run.new()
	run.start(Run.EVENING, randi(), randi() % 2 + 3)
	var view := GameView.new()
	add_child(view)
	_world = World.new()
	_world.setup(run, true)
	_world.camera_shift = Vector2(-86, 0)
	view.show_world(_world)
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	var ui := Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(ui)
	_shaker = Control.new()
	_shaker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shaker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(_shaker)
	_shaker.add_child(TitleSlab.new())
	_ticker = Ticker.new()
	_shaker.add_child(_ticker)
	var logo := Logo.new()
	logo.position = Vector2(44, 20)
	logo.size = Vector2(800, 460)
	_shaker.add_child(logo)
	var column := VBoxContainer.new()
	column.position = Vector2(78, 500)
	column.custom_minimum_size.x = 560
	column.add_theme_constant_override("separation", 6)
	_shaker.add_child(column)
	_add(column, "PLAY", func() -> void: Game.main.show_screen("play", {"mode": Run.EVENING}, 0.25))
	if Game.wins > 0:
		_add(column, "GRAVEYARD", func() -> void: Game.main.show_screen("play", {"mode": Run.GRAVEYARD}, 0.25))
	_add(column, "HOW TO PLAY", func() -> void: Game.main.show_screen("help", {}, 0.2))
	_add(column, "HIGH SCORES", func() -> void: Game.main.show_screen("scores", {}, 0.2))
	_add(column, "OPTIONS", func() -> void: Game.main.show_screen("options", {}, 0.2))
	_add(column, "CREDITS", func() -> void: Game.main.show_screen("credits", {}, 0.2))
	_add(column, "QUIT", func() -> void: get_tree().quit())
	UI.link_focus(_buttons)
	for i in _buttons.size():
		# They follow the slab's slant down the screen.
		_buttons[i].indent = -float(i) * 14.0
		_buttons[i].index = i
		_buttons[i].pop_in(0.25 + i * 0.05)
	_buttons[0].grab_focus()
	if Game.best_score() > 0:
		var best := BestPlate.new()
		_shaker.add_child(best)
	Audio.heat = 0.5
	Audio.play_music("title", 1.0)


func _process(_delta: float) -> void:
	if UI.fx:
		_shaker.position = UI.fx.offset


func _add(column: Control, text: String, on_press: Callable) -> void:
	var b := SmaskButton.new(text, 32)
	b.custom_minimum_size.y = 66
	b.pressed.connect(on_press)
	column.add_child(b)
	_buttons.append(b)


## The slab, its coloured edges, and the version in its corner.
class TitleSlab extends Control:
	var _version := Game.version_text()
	var _t := 0.0

	func _ready() -> void:
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _process(delta: float) -> void:
		_t = minf(_t + delta / 0.35, 1.0)
		queue_redraw()

	func _draw() -> void:
		var k := UI.cubic_out(_t)
		var h := size.y
		var bleed := UiFx.MOST_SHAKE + 10.0
		var top := 930.0 * k
		var bottom := 660.0 * k
		for band: Array in [[56.0, UI.glow(UI.PINK, 1.25)], [34.0, UI.hue()], [14.0, UI.YELLOW]]:
			var w: float = band[0]
			UI.fill(self, PackedVector2Array([Vector2(-bleed, -bleed), Vector2(top + w, -bleed), Vector2(bottom + w, h + bleed), Vector2(-bleed, h + bleed)]), band[1])
		UI.fill(self, PackedVector2Array([Vector2(-bleed, -bleed), Vector2(top, -bleed), Vector2(bottom, h + bleed), Vector2(-bleed, h + bleed)]), UI.INK)
		UI.outlined(self, UI.body_font(), Vector2(30, h - 12.0), _version, 20, UI.DIM)


## A slanted band running across the bottom of the game side, saying what to do.
class Ticker extends Control:
	const TEXT := "SMASK EVERYTHING  ///  COUNT TO ZERO  ///  REACH MIDNIGHT  ///  "

	func _ready() -> void:
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		var font := UI.display_font()
		var font_size := 34
		var at := Vector2(680, size.y - 58.0)
		UI.tilt(self, at, -0.025, 1.0, 0.0)
		UI.rect(self, Rect2(-60, -44, size.x + 200.0, 66), UI.YELLOW)
		UI.rect(self, Rect2(-60, 22, size.x + 200.0, 8), UI.INK)
		var w := UI.text_width(font, TEXT, font_size)
		var x := -fposmod(Time.get_ticks_msec() * 0.15, w)
		for i in 4:
			draw_string(font, Vector2(x + i * w, 0), TEXT, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, UI.INK)
		UI.straight(self)


class BestPlate extends Control:
	func _ready() -> void:
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		var text := UI.format_score(Game.best_score())
		var w := UI.text_width(UI.title_font(), text, 44)
		var r := Rect2(Vector2(size.x - w - 170.0, 34), Vector2(w + 130.0, 78))
		UI.plate(self, r, UI.INK, UI.hue(0.3), 0.3)
		UI.outlined(self, UI.display_font(), r.position + Vector2(24, 48), "BEST", 22, UI.YELLOW)
		UI.outlined(self, UI.title_font(), r.position + Vector2(104, 58), text, 44, UI.WHITE)
