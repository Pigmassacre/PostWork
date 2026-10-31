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
		draw_rect(Rect2(at - Vector2(3, 3), Vector2(6, 6)), UI.YELLOW)
		return
	var k := 1.0 - _kick * 0.25
	draw_set_transform(at, 0.0, Vector2(k, k))
	var arrow := PackedVector2Array([Vector2(0, 0), Vector2(44, 18), Vector2(20, 24), Vector2(10, 46)])
	draw_colored_polygon(PackedVector2Array([Vector2(-6, -8), Vector2(58, 18), Vector2(26, 30), Vector2(10, 62)]), UI.INK)
	draw_colored_polygon(arrow, UI.YELLOW)
	draw_set_transform_matrix(Transform2D.IDENTITY)
