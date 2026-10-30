class_name TouchControls
extends Control
## When played by finger: the left half of the screen's a stick wherever the thumb
## lands, and anything on the right half is the SMASK, held.

const REACH := 26.0

var _stick_finger := -1
var _stick_from := Vector2.ZERO
var _smask_finger := -1


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var at := _to_local(event.position)
		if event.pressed:
			if at.x > size.x - 24.0 and at.y < 24.0:
				var press := InputEventAction.new()
				press.action = "pause"
				press.pressed = true
				Input.parse_input_event(press)
			elif at.x < size.x * 0.5 and _stick_finger < 0:
				_stick_finger = event.index
				_stick_from = at
			elif _smask_finger < 0:
				_smask_finger = event.index
				Inputs.touch_smask = true
		else:
			if event.index == _stick_finger:
				_stick_finger = -1
				Inputs.touch_move = Vector2.ZERO
			elif event.index == _smask_finger:
				_smask_finger = -1
				Inputs.touch_smask = false
		queue_redraw()
	elif event is InputEventScreenDrag and event.index == _stick_finger:
		Inputs.touch_move = ((_to_local(event.position) - _stick_from) / REACH).limit_length(1.0)
		queue_redraw()


func _to_local(screen: Vector2) -> Vector2:
	return get_viewport().get_screen_transform().affine_inverse() * screen


func _exit_tree() -> void:
	Inputs.touch_move = Vector2.ZERO
	Inputs.touch_smask = false


func _draw() -> void:
	if _stick_finger >= 0:
		draw_arc(_stick_from, REACH, 0.0, TAU, 24, Color(1, 1, 1, 0.3))
		draw_circle(_stick_from + Inputs.touch_move * REACH, 6.0, Color(1, 1, 1, 0.35))
