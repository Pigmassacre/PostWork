class_name Wipe
extends Control
## Between screens: slanted bands slam across from alternating sides, the screen
## swaps behind them, and they carry on out.

const BANDS := 7
const TIME_IN := 0.3
const TIME_OUT := 0.34
const COLORS := [UI.INK, UI.YELLOW, UI.INK, UI.PINK, UI.INK, UI.CYAN, UI.INK]

var _t := 0.0
var _covering := false
var _revealing := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## The screen's covered when this returns.
func cover() -> void:
	_covering = true
	_revealing = false
	_t = 0.0
	mouse_filter = Control.MOUSE_FILTER_STOP
	Audio.play("smask", -14.0, 1.5)
	await get_tree().create_timer(TIME_IN, true, false, true).timeout


func reveal() -> void:
	_covering = false
	_revealing = true
	_t = 0.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if UI.fx:
		UI.fx.shake(4.0)


func _process(delta: float) -> void:
	if not _covering and not _revealing:
		return
	_t += delta
	if _revealing and _t >= TIME_OUT:
		_revealing = false
	queue_redraw()


func _draw() -> void:
	if not _covering and not _revealing:
		return
	var h := (size.y + 60.0) / BANDS
	for i in BANDS:
		var from := -1.0 if i % 2 == 0 else 1.0
		var delay := i * 0.022
		var x := 0.0
		if _covering:
			x = (1.0 - UI.cubic_out((_t - delay) / (TIME_IN - BANDS * 0.022))) * from * (size.x + 400.0)
		else:
			x = -UI.cubic_out((_t - delay) / (TIME_OUT - BANDS * 0.022)) * from * (size.x + 400.0)
		var rect := Rect2(Vector2(x - 200.0, i * h - 30.0), Vector2(size.x + 400.0, h + 2.0))
		UI.slab(self, rect, COLORS[i], 0.6)
