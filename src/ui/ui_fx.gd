class_name UiFx
extends Control
## Over all the menus and the HUD: full-resolution sparks and rings, a flash, and
## the shake that whatever's listening follows.

class Spark:
	var pos: Vector2
	var vel: Vector2
	var life: float
	var total: float
	var color: Color
	var size: float
	var spin: float

class Ring:
	var pos: Vector2
	var radius: float
	var age := 0.0
	var total: float
	var color: Color

var offset := Vector2.ZERO
var _trauma := 0.0
var _flash := 0.0
var _flash_color := Color.WHITE
var _sparks: Array[Spark] = []
var _rings: Array[Ring] = []
var _time := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func sparks(at: Vector2, color: Color, count := 12, speed := 620.0) -> void:
	for i in count:
		var s := Spark.new()
		s.pos = at
		s.vel = Vector2.from_angle(randf() * TAU) * randf_range(0.25, 1.0) * speed
		s.total = randf_range(0.25, 0.6)
		s.life = s.total
		s.color = color if randf() < 0.7 else UI.WHITE
		s.size = randf_range(6.0, 16.0)
		s.spin = randf() * TAU
		_sparks.append(s)
	if _sparks.size() > 300:
		_sparks = _sparks.slice(_sparks.size() - 300)


func ring(at: Vector2, radius: float, color: Color, seconds := 0.35) -> void:
	var r := Ring.new()
	r.pos = at
	r.radius = radius
	r.total = seconds
	r.color = color
	_rings.append(r)


func flash(color: Color, amount: float) -> void:
	_flash_color = color
	_flash = maxf(_flash, amount if Game.settings.flashes else amount * 0.25)


func shake(amount: float) -> void:
	_trauma = minf(_trauma + amount * float(Game.settings.shake), 60.0)


func _process(delta: float) -> void:
	_time += delta
	_trauma = maxf(_trauma - (_trauma * 5.0 + 8.0) * delta, 0.0)
	_flash = maxf(_flash - delta * 3.5, 0.0)
	offset = Vector2(sin(_time * 83.0) + sin(_time * 41.0), cos(_time * 71.0) + sin(_time * 53.0)) * 0.5 * _trauma
	var i := 0
	while i < _sparks.size():
		var s := _sparks[i]
		s.life -= delta
		if s.life <= 0.0:
			_sparks[i] = _sparks[_sparks.size() - 1]
			_sparks.pop_back()
			continue
		s.pos += s.vel * delta
		s.vel *= exp(-3.5 * delta)
		s.spin += delta * 9.0
		i += 1
	i = 0
	while i < _rings.size():
		_rings[i].age += delta
		if _rings[i].age >= _rings[i].total:
			_rings.remove_at(i)
		else:
			i += 1
	if not _sparks.is_empty() or not _rings.is_empty() or _flash > 0.0 or _was_busy:
		queue_redraw()
	_was_busy = not _sparks.is_empty() or not _rings.is_empty() or _flash > 0.0


var _was_busy := false


func _draw() -> void:
	for r in _rings:
		var t := r.age / r.total
		draw_arc(r.pos, r.radius * UI.cubic_out(t), 0.0, TAU, 64, Color(UI.glow(r.color, 2.4), 1.0 - t), 14.0 * (1.0 - t) + 1.0, true)
	for s in _sparks:
		var k := s.life / s.total
		var size := s.size * k
		draw_set_transform(s.pos, s.spin, Vector2.ONE)
		UI.rect(self, Rect2(Vector2(-size, -size * 0.4), Vector2(size * 2.0, size * 0.8)), Color(UI.glow(s.color, 2.2), minf(k * 2.0, 1.0)))
	draw_set_transform_matrix(Transform2D.IDENTITY)
	if _flash > 0.0:
		draw_rect(Rect2(Vector2.ZERO, size), Color(_flash_color, _flash * 0.6))
