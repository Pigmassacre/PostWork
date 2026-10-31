class_name Backdrop
extends Control
## Behind the menus: the sunburst going round, and SMASK in enormous letters
## sliding past at an angle.

const ROWS := 4
const WORD := "SMASK ZERO SMASK ZERO SMASK ZERO "

var hue_offset := 0.0
var _rays: ColorRect
var _material: ShaderMaterial


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_rays = ColorRect.new()
	_rays.show_behind_parent = true
	_rays.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rays.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_material = ShaderMaterial.new()
	_material.shader = preload("res://src/fx/rays.gdshader")
	_rays.material = _material
	add_child(_rays)


func _process(_delta: float) -> void:
	_material.set_shader_parameter("hue", UI.hue(hue_offset).h)
	_material.set_shader_parameter("aspect", size.x / maxf(size.y, 1.0))
	queue_redraw()


func _draw() -> void:
	var font := UI.title_font()
	var font_size := 170
	var width := UI.text_width(font, WORD, font_size)
	var time := Time.get_ticks_msec() * 0.001
	for row in ROWS:
		var dir := 1.0 if row % 2 == 0 else -1.0
		var y := float(row) * 300.0 + 40.0
		var x := fposmod(time * 70.0 * dir, width) - width
		UI.tilt(self, Vector2(0, y), -0.09, 1.0, -0.18)
		for i in 3:
			draw_string(font, Vector2(x + i * width - 200.0, 0), WORD, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(1, 1, 1, 0.05))
	UI.straight(self)
