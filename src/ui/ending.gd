extends Node
## 00:00. The clock's gone, and it's tomorrow.

const LINES := [
	"YOU WIN",
	"See you at work.",
]

var _shown := 0.0
var _run: Run
var _sheet: Control
var _done := false


func open(args: Dictionary) -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run = args.run
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	var ui := Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(ui)
	ui.add_child(Backdrop.new())
	_sheet = Control.new()
	_sheet.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_sheet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sheet.draw.connect(_draw_sheet)
	ui.add_child(_sheet)
	Audio.heat = 0.0
	Audio.play_music("ending", 2.0)
	UI.fx.flash(UI.WHITE, 1.0)
	UI.fx.shake(40.0)
	UI.fx.sparks(ui.size * 0.5, UI.YELLOW, 80, 1800.0)


func _process(delta: float) -> void:
	_shown += delta
	_sheet.position = UI.fx.offset
	_sheet.queue_redraw()
	_done = _shown > 3.0


func _draw_sheet() -> void:
	var size := _sheet.size
	var mid := Vector2(size.x * 0.5, size.y * 0.3)
	var k := UI.back_out(_shown / 0.4, 1.3)
	UI.burst(_sheet, mid, 200.0, 1400.0, 20, _shown * 0.2, Color(UI.YELLOW, 0.12))
	UI.tilt(_sheet, mid, -0.05, 2.6 - 1.6 * k, -0.14)
	UI.centred(_sheet, UI.title_font(), Vector2(8, 8), "00:00", 190, UI.PINK, 40)
	UI.centred(_sheet, UI.title_font(), Vector2.ZERO, "00:00", 190, UI.YELLOW)
	UI.straight(_sheet)
	var y := size.y * 0.52
	for i in LINES.size():
		var t := (_shown - 0.7 - i * 0.7) / 0.3
		if t <= 0.0:
			continue
		var x := size.x * 0.5 + (1.0 - UI.back_out(t)) * -1800.0
		var line: String = LINES[i]
		UI.centred(_sheet, UI.display_font() if i == 0 else UI.body_font(), Vector2(x, y + i * 66.0), line, 72 if i == 0 else 40, UI.WHITE, 14)
	var t2 := (_shown - 2.2) / 0.3
	if t2 > 0.0:
		var plate := Rect2(Vector2(size.x * 0.5 - 500.0, y + 200.0 + (1.0 - UI.back_out(t2)) * 700.0), Vector2(1000, 120))
		UI.plate(_sheet, plate, UI.INK, UI.YELLOW)
		var text := "%s   ///   %s" % [UI.format_score(_run.score), UI.format_time(_run.time)]
		UI.centred(_sheet, UI.title_font(), plate.get_center(), text, 56, UI.YELLOW)
		UI.centred(_sheet, UI.display_font(), plate.get_center() + Vector2(0, 130), "GRAVEYARD UNLOCKED", 34, UI.GREEN, 12)


func _unhandled_input(event: InputEvent) -> void:
	if _done and (event.is_action_pressed("ui_accept") or event.is_action_pressed("pause") or event is InputEventMouseButton and event.pressed):
		get_viewport().set_input_as_handled()
		Game.main.show_screen("title", {}, 0.5)
