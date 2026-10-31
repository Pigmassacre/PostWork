class_name Cursor
extends Control
## The pointer, in full resolution: a slanted arrow that kicks when you click, and
## a turning target while you're flying at it.

var flying := false
var _kick := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_kick = 1.0
		if UI.fx and not flying:
			UI.fx.sparks(get_global_mouse_position(), UI.YELLOW, 6, 300.0)


func _process(delta: float) -> void:
	_kick = maxf(_kick - delta * 8.0, 0.0)
	queue_redraw()


func _draw() -> void:
	var at := get_global_mouse_position()
	if flying:
		var turning := Time.get_ticks_msec() * 0.003
		draw_arc(at, 24.0 - _kick * 8.0, turning, turning + TAU * 0.8, 24, UI.INK, 8.0, true)
		draw_arc(at, 24.0 - _kick * 8.0, turning, turning + TAU * 0.8, 24, UI.YELLOW, 4.0, true)
		draw_circle(at, 3.5, UI.YELLOW, true, -1.0, true)
		return
	var k := 1.0 - _kick * 0.25
	draw_set_transform(at, 0.0, Vector2(k, k))
	UI.fill(self, UI.round_corners(PackedVector2Array([Vector2(-7, -9), Vector2(56, 17), Vector2(9, 60)]), 5.0), UI.INK)
	UI.fill(self, UI.round_corners(PackedVector2Array([Vector2(0, 0), Vector2(42, 17), Vector2(10, 46)]), 3.0), UI.YELLOW)
	draw_set_transform_matrix(Transform2D.IDENTITY)
