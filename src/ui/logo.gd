class_name Logo
extends Control
## SUPER SMASK ZERO, as the original's start screen had it (rocking two degrees
## either way over four seconds, breathing with it), only now it's enormous and
## vector-sharp, with a chrome SMASK whose letters jump, and which slams every so often.

const SLAM_EVERY := 4.0
const SMASK := "SMASK"

var _time := 0.0
var _intro := 0.0
var _slam := 0.0
var _slam_clock := 2.2
var _smask_material: ShaderMaterial
var _smask_layer: LogoSmask


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(800, 460)
	_smask_material = ShaderMaterial.new()
	_smask_material.shader = preload("res://src/fx/shine.gdshader")
	_smask_material.set_shader_parameter("top", Color("fffbe0"))
	_smask_material.set_shader_parameter("middle", UI.YELLOW)
	_smask_material.set_shader_parameter("bottom", UI.ORANGE)
	_smask_material.set_shader_parameter("from_y", -110.0)
	_smask_material.set_shader_parameter("to_y", 20.0)
	_smask_layer = LogoSmask.new()
	_smask_layer.logo = self
	_smask_layer.material = _smask_material
	add_child(_smask_layer)


func _process(delta: float) -> void:
	_time += delta
	if _intro < 1.0:
		_intro = minf(_intro + delta / 0.5, 1.0)
		if _intro >= 1.0:
			_slam_now()
	_slam = maxf(_slam - delta * 3.5, 0.0)
	_slam_clock -= delta
	if _slam_clock <= 0.0:
		_slam_clock = SLAM_EVERY
		_slam_now()
	var wave := sin(_time * PI * 0.5)
	pivot_offset = size * 0.5
	rotation_degrees = wave * 2.0
	modulate.a = 0.9 + wave * 0.1
	scale = Vector2.ONE * (1.0 + (1.0 - UI.back_out(_intro, 1.0)) * 2.4)
	queue_redraw()
	_smask_layer.queue_redraw()


func _slam_now() -> void:
	_slam = 1.0
	if UI.fx:
		UI.fx.shake(14.0)
		UI.fx.sparks(global_position + Vector2(size.x * 0.5, 220.0), UI.YELLOW, 20, 1000.0)
	Audio.play("hit", -8.0, 0.7)


func letter_at(i: int) -> Vector2:
	var hop := pow(maxf(sin(_time * 3.0 - i * 0.7), 0.0), 8.0)
	return Vector2(0, -hop * 26.0 - _slam * ((i + 1) % 2 * 2.0 - 1.0) * 10.0)


func smask_scale() -> float:
	return 1.0 + _slam * 0.1


func _draw() -> void:
	var font := UI.logo_font()
	# Rays behind the word, turning.
	UI.burst(self, Vector2(size.x * 0.5, 220.0), 90.0, 520.0 + _slam * 80.0, 18, _time * 0.25, Color(UI.hue(0.5), 0.2))
	# SUPER: white on a slab, leaning.
	UI.tilt(self, Vector2(28, 60), -0.05, 1.0, -0.2)
	UI.slab(self, Rect2(-20, -18, 420, 96), UI.PINK, 0.3)
	draw_string(font, Vector2(14, 56), "SUPER", HORIZONTAL_ALIGNMENT_LEFT, -1, 86, UI.WHITE)
	# The extrusion under SMASK, in its own letters' positions.
	UI.tilt(self, Vector2(size.x * 0.5, 280.0), -0.05, smask_scale(), -0.16)
	var widths := _letter_lefts(font)
	for i in SMASK.length():
		var at: Vector2 = widths[i] + letter_at(i)
		for depth in range(12, 0, -2):
			draw_string(font, at + Vector2(depth, depth), SMASK[i], HORIZONTAL_ALIGNMENT_LEFT, -1, LogoSmask.SIZE, UI.INK if depth > 6 else Color("b5125a"))
	# ZERO: the colour that goes round, as the original's floor.
	UI.tilt(self, Vector2(size.x - 40.0, 408.0), -0.05, 1.0, -0.2)
	var zero_w := UI.text_width(font, "ZERO", 112)
	UI.outlined(self, font, Vector2(-zero_w, 0), "ZERO", 112, UI.hue(0.1), 22)
	UI.straight(self)


func _letter_lefts(font: Font) -> Array:
	var total := UI.text_width(font, SMASK, LogoSmask.SIZE)
	var lefts := []
	var x := -total * 0.5
	for i in SMASK.length():
		lefts.append(Vector2(x, 0))
		x += UI.text_width(font, SMASK[i], LogoSmask.SIZE)
	return lefts


class LogoSmask extends Control:
	const SIZE := 214
	var logo: Logo

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var font := UI.logo_font()
		UI.tilt(self, Vector2(logo.size.x * 0.5, 280.0), -0.05, logo.smask_scale(), -0.16)
		var lefts := logo._letter_lefts(font)
		for i in Logo.SMASK.length():
			draw_string(font, lefts[i] + logo.letter_at(i), Logo.SMASK[i], HORIZONTAL_ALIGNMENT_LEFT, -1, SIZE)
		UI.straight(self)
