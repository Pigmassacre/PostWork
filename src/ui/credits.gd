extends MenuScreen
## Who made what.


func _ready() -> void:
	build("CREDITS", false)
	var sheet := CreditSheet.new()
	sheet.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	body.add_child(sheet)


class CreditSheet extends Control:
	var _text := FileAccess.get_file_as_string("res://src/data/credits.txt")
	var _t := 0.0

	func _process(delta: float) -> void:
		_t = minf(_t + delta / 0.3, 1.0)
		queue_redraw()

	func _draw() -> void:
		var k := UI.back_out(_t)
		var r := Rect2(Vector2((1.0 - k) * 1600.0, 0), Vector2(size.x, size.y))
		UI.plate(self, r, UI.INK, UI.hue(), 0.04)
		UI.paragraph(self, r.position + Vector2(44, 62), _text.replace("SUPER SMASK ZERO\n\n", ""), size.x - 88.0, 29, UI.WHITE)
