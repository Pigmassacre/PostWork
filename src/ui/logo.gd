class_name Logo
extends Control
## SUPER SMASK ZERO. The letters of SMASK slam down one by one on a comic star. Then the
## ship itself, in its big fat pixels, smashes through the word in one go, knocking every
## letter flying, bursts out of the K and overshoots, and settles back on the end of the
## word, its trail left burning through the letters: that's the logo. The hit shorts ZERO
## on, a neon sign with a clock in its O. SMASK rocks two degrees either way over four
## seconds, as the original's start screen did. The ship and its line hold steady through
## it: every so often a pulse of light runs up the line, and the ship surges on it. SUPER
## leans and slides, as if it's still going some speed; ZERO hums, swelling and brightening.

const SMASK := "SMASK"
const SIZE := 148
const ZERO_SIZE := 92
const CENTRE := Vector2(400, 244)
const ZERO_MIDDLE := Vector2(620, 352)
const TILT := -0.05
const LEAN := -0.16
const LAND_START := 0.12
const LAND_GAP := 0.05
const LAND_TIME := 0.16
const ZERO_GLITCH := 0.34
const BURST_TIME := 0.42
const SHIP_AT := 0.42
const STRIKE_TIME := 0.62
## A long frame mustn't blow the letters' springs up.
const MOST_STEP := 1.0 / 30.0
const PASS_FROM := -640.0
const PARK_AT := 432.0
const TRAIL_FROM := -440.0
const PULSE_EVERY := 1.7
## How much of that the pulse takes to run up the line; the rest's the ship's surge.
const PULSE_RUN := 0.45
const SURGE := 9.0

enum Flight { WAITING, STRIKING, PARKED }

var _time := 0.0
var _offsets: Array[Vector2] = []
var _velocities: Array[Vector2] = []
var _turns: Array[float] = []
var _spins: Array[float] = []
var _lands: Array[bool] = []
var _hit: Array[float] = []
var _passed: Array[bool] = []
var _lefts: Array[float] = []
var _widths: Array[float] = []
var _flight := Flight.WAITING
var _flight_clock := SHIP_AT
var _flight_t := 0.0
var _struck := false
## The ship, along the word.
var ship_at := Vector2(PASS_FROM, 0)
var ship_speed := 0.0
## How far along the word the trail it leaves goes.
var trail_end := TRAIL_FROM
var _pop := 0.0
var _rock := 0.0
var _parked_time := 0.0
## When the hit started ZERO going; below 0, it hasn't.
var _zero_from := -1.0
var _zero_landed := false
## How far through its ring the hit is, 0 to 1; 1 and it's over.
var burst := 1.0
## Where along the word it went off.
var burst_x := 0.0
var _smask_layer: LogoSmask
var _zero_layer: LogoZero
var _top_layer: LogoTop


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(800, 460)
	var font := UI.title_font()
	var x := -UI.text_width(font, SMASK, SIZE) * 0.5
	for i in SMASK.length():
		var w := UI.text_width(font, SMASK[i], SIZE)
		_lefts.append(x)
		_widths.append(w)
		x += w
		_offsets.append(Vector2.ZERO)
		_velocities.append(Vector2.ZERO)
		_turns.append(0.0)
		_spins.append(0.0)
		_lands.append(false)
		_hit.append(0.0)
		_passed.append(false)
	var shine := ShaderMaterial.new()
	shine.shader = preload("res://src/fx/shine.gdshader")
	shine.set_shader_parameter("top", Color(1.25, 1.2, 1.0))
	shine.set_shader_parameter("middle", Color(1.0, 0.92, 0.12))
	shine.set_shader_parameter("bottom", Color(1.0, 0.3, 0.05))
	shine.set_shader_parameter("from_y", -SIZE * 0.42)
	shine.set_shader_parameter("to_y", SIZE * 0.42)
	_smask_layer = LogoSmask.new()
	_smask_layer.logo = self
	_smask_layer.material = shine
	add_child(_smask_layer)
	_zero_layer = LogoZero.new()
	_zero_layer.logo = self
	add_child(_zero_layer)
	_top_layer = LogoTop.new()
	_top_layer.logo = self
	add_child(_top_layer)


func _process(frame_time: float) -> void:
	var delta := minf(frame_time, MOST_STEP)
	_time += delta
	_pop = maxf(_pop - delta * 3.5, 0.0)
	burst = minf(burst + delta / BURST_TIME, 1.0)
	_land_letters()
	_fly_ship(delta)
	if _flight == Flight.PARKED:
		_parked_time += delta
	for i in SMASK.length():
		_hit[i] = maxf(_hit[i] - delta * 7.0, 0.0)
		# Each letter's on a spring back to where it belongs.
		_velocities[i] += (-_offsets[i] * 170.0 - _velocities[i] * 11.0) * delta
		_offsets[i] += _velocities[i] * delta
		_spins[i] += (-_turns[i] * 170.0 - _spins[i] * 10.0) * delta
		_turns[i] += _spins[i] * delta
	_rock = deg_to_rad(sin(_time * PI * 0.5) * 2.0)
	queue_redraw()
	_smask_layer.queue_redraw()
	_zero_layer.queue_redraw()
	_top_layer.queue_redraw()


func _land_letters() -> void:
	for i in SMASK.length():
		if not _lands[i] and _time >= _land_at(i) + LAND_TIME:
			_lands[i] = true
			_velocities[i] = Vector2(0, 520)
			_spins[i] = (1.0 if i % 2 == 0 else -1.0) * 3.0
			_pop = 1.0
			if UI.fx:
				UI.fx.shake(5.0 + i)
				UI.fx.sparks(_on_screen(_letter_centre(i)), UI.YELLOW, 12, 800.0)
			Audio.play("hit", -7.0, 0.65 + i * 0.1)
	if not _zero_landed and _zero_from >= 0.0 and _time >= _zero_from + ZERO_GLITCH:
		_zero_landed = true
		if UI.fx:
			UI.fx.shake(3.0)
			UI.fx.sparks(get_global_transform() * ZERO_MIDDLE, UI.hue(0.1), 14, 700.0)
		Audio.play("tick", -5.0, 1.5)


func _fly_ship(delta: float) -> void:
	match _flight:
		Flight.WAITING:
			_flight_clock -= delta
			if _flight_clock <= 0.0:
				_flight = Flight.STRIKING
				Audio.play("smask", -9.0, 1.0)
		Flight.STRIKING:
			_flight_t += delta / STRIKE_TIME
			var was := ship_at.x
			ship_at.x = lerpf(PASS_FROM, PARK_AT, UI.back_out(minf(_flight_t, 1.0)))
			ship_speed = (ship_at.x - was) / maxf(delta, 0.001)
			trail_end = ship_at.x - 44.0
			_knock_as_it_goes()
			# Out of the end of the word: the ring goes off right there, and the ship flies on out of it.
			var word_end := _lefts[SMASK.length() - 1] + _widths[SMASK.length() - 1]
			if not _struck and ship_at.x >= word_end:
				_struck = true
				burst = 0.0
				burst_x = word_end
				_zero_from = _time
				if UI.fx:
					UI.fx.sparks(_on_screen(Vector2(word_end, 0)), UI.YELLOW, 24, 1000.0)
					UI.fx.shake(10.0)
				Audio.play("boom", -8.0, 0.8)
			if _flight_t >= 1.0:
				_flight = Flight.PARKED
				ship_at.x = PARK_AT
				ship_speed = 0.0


func _knock_as_it_goes() -> void:
	for i in SMASK.length():
		if not _passed[i] and ship_at.x >= _lefts[i] + _widths[i] * 0.5:
			_passed[i] = true
			var way := -1.0 if i % 2 == 0 else 1.0
			_velocities[i] += Vector2(620.0, way * 1150.0)
			_spins[i] += way * 11.0
			_hit[i] = 1.0
			if UI.fx:
				UI.fx.sparks(_on_screen(_letter_centre(i)), UI.YELLOW, 16, 1200.0)
				UI.fx.shake(5.4)
			Audio.play("hit", -9.0, 0.7 + i * 0.12)


func _land_at(i: int) -> float:
	return LAND_START + i * LAND_GAP


func _letter_centre(i: int) -> Vector2:
	return Vector2(_lefts[i] + _widths[i] * 0.5, 0)


func _on_screen(on_word: Vector2) -> Vector2:
	return get_global_transform() * (ship_transform() * on_word)


func flight() -> Flight:
	return _flight


func flame_time() -> float:
	return _time


## The line the ship and its trail are on.
func ship_transform() -> Transform2D:
	return Transform2D(TILT, CENTRE)


## How far through its beat the idling ship is, 0 to 1.
func _beat() -> float:
	return fposmod(_parked_time / PULSE_EVERY, 1.0)


## How far along the line the pulse has got, 0 to 1; below 0, there's none just now.
func pulse() -> float:
	if _parked_time <= 0.0 or _beat() >= PULSE_RUN:
		return -1.0
	return _beat() / PULSE_RUN


## How far ahead of where it's parked the ship's surged, 0 to 1.
func surge() -> float:
	if _parked_time <= 0.0 or _beat() < PULSE_RUN:
		return 0.0
	return pow(sin(sqrt((_beat() - PULSE_RUN) / (1.0 - PULSE_RUN)) * PI), 2.0)


## How a letter's drawn: down from too close as it lands, then on its spring.
func letter_transform(i: int) -> Transform2D:
	var word := Transform2D(TILT + _rock, Vector2.ONE, LEAN, CENTRE)
	var k := clampf((_time - _land_at(i)) / LAND_TIME, 0.0, 1.0)
	var scale_now := 1.0 + (1.0 - k * k) * 3.0 + _pop * 0.03
	var at := _letter_centre(i) + _offsets[i]
	return word * Transform2D(_turns[i], Vector2(scale_now, scale_now), 0.0, at)


func letter_shown(i: int) -> bool:
	return _time >= _land_at(i)


func hit_of(i: int) -> float:
	return _hit[i]


func width_of(i: int) -> float:
	return _widths[i]


func _draw() -> void:
	_draw_star()
	_draw_super()
	_draw_extrusion()
	draw_set_transform_matrix(Transform2D.IDENTITY)


func _draw_star() -> void:
	var k := UI.back_out((_time - LAND_START) / 0.3, 2.2)
	if _time < LAND_START:
		return
	var grow := _pop * 0.12 + sin(_time * 5.0) * 0.012
	var radius := Vector2(405, 138) * k
	UI.burst(self, CENTRE, 150.0, 480.0, 18, _time * 0.25, Color(UI.glow(UI.hue(0.5), 1.1), 0.3))
	UI.star(self, CENTRE, radius, 15, 3, grow + 0.05, UI.glow(UI.PINK, 1.5))
	UI.star(self, CENTRE, radius, 15, 3, grow, UI.INK)


func _draw_super() -> void:
	var k := UI.back_out(_time / 0.24, 1.6)
	var drift := sin(_time * 2.3)
	var at := Vector2(34 + (1.0 - k) * -700.0 + drift * 8.0, 137)
	# It's been going some speed, and it's still leaning into it.
	UI.tilt(self, at, -0.07, 1.0, -0.22 - drift * 0.05)
	for line: Array in [[-10.0, 130.0], [14.0, 210.0], [38.0, 90.0]]:
		UI.streak(self, Vector2(-30.0 - line[1] * (1.0 + drift * 0.25), line[0]), Vector2(-16.0, line[0]), 6.0, Color(UI.glow(UI.WHITE, 1.2), 0.8))
	UI.slab(self, Rect2(-14, -36, 376, 96), UI.glow(UI.PINK, 1.25), 0.3)
	draw_string(UI.title_font(), Vector2(22, 41), "SUPER", HORIZONTAL_ALIGNMENT_LEFT, -1, 66, Color(0, 0, 0, 0.4))
	draw_string(UI.title_font(), Vector2(18, 37), "SUPER", HORIZONTAL_ALIGNMENT_LEFT, -1, 66, UI.WHITE)


## Under the chrome: each letter thick, pink going to black, with a neon rim.
func _draw_extrusion() -> void:
	var font := UI.title_font()
	for i in SMASK.length():
		if not letter_shown(i):
			continue
		draw_set_transform_matrix(letter_transform(i))
		var at := Vector2(-_widths[i] * 0.5, SIZE * 0.36)
		for depth in range(16, 0, -2):
			var c: Color = UI.INK if depth > 8 else Color("b5125a")
			draw_string(font, at + Vector2(depth, depth), SMASK[i], HORIZONTAL_ALIGNMENT_LEFT, -1, SIZE, c)
		draw_string_outline(font, at, SMASK[i], HORIZONTAL_ALIGNMENT_LEFT, -1, SIZE, 7, UI.glow(UI.YELLOW.lerp(UI.ORANGE, 0.4), 1.6))


## A neon sign: hollow, flickering a little, with a clock going round in its O. The hit
## shorts it on where it stands: stuttering, jumping about and splitting into colours,
## steadier and steadier until it locks.
func draw_zero(c: CanvasItem) -> void:
	if _zero_from < 0.0:
		return
	var font := UI.title_font()
	var t := clampf((_time - _zero_from) / ZERO_GLITCH, 0.0, 1.0)
	var settle := 1.0 - t
	var hum := sin(_time * 3.7)
	var jump := Vector2.ZERO
	var stretch := Vector2.ONE
	var split := 0.0
	if t < 1.0:
		# The same few wrong frames every time, thirty a second.
		var beat_of := float(int((_time - _zero_from) * 30.0))
		if _noise(beat_of) > 0.35 + t * 0.9:
			return
		jump = Vector2((_noise(beat_of + 0.3) - 0.5) * 46.0, (_noise(beat_of + 0.6) - 0.5) * 14.0) * settle
		stretch = Vector2(1.0 + _noise(beat_of + 0.8) * 0.3 * settle, 1.0 - _noise(beat_of + 0.9) * 0.3 * settle)
		split = 12.0 * settle
	else:
		# And a little pop as it locks.
		var after := clampf((_time - _zero_from - ZERO_GLITCH) / 0.14, 0.0, 1.0)
		stretch = Vector2.ONE * (1.0 + (1.0 - after) * (1.0 - after) * 0.07 + hum * 0.025 * after)
	c.draw_set_transform_matrix(Transform2D(-0.05, stretch, -0.2, ZERO_MIDDLE + jump))
	var w := UI.text_width(font, "ZERO", ZERO_SIZE)
	var left := Vector2(-w * 0.5, ZERO_SIZE * 0.36)
	if split > 0.0:
		c.draw_string_outline(font, left + Vector2(-split, 0), "ZERO", HORIZONTAL_ALIGNMENT_LEFT, -1, ZERO_SIZE, 10, UI.glow(UI.PINK, 1.6))
		c.draw_string_outline(font, left + Vector2(split, 0), "ZERO", HORIZONTAL_ALIGNMENT_LEFT, -1, ZERO_SIZE, 10, UI.glow(UI.CYAN, 1.6))
	# Now and then a tube stutters.
	var flicker := 1.0 + hum * 0.22
	var beat := fmod(_time, 5.3)
	if beat < 0.22 and int(beat * 40.0) % 2 == 0:
		flicker = 0.35
	var neon := UI.glow(UI.hue(0.1), 1.5 * flicker)
	c.draw_string_outline(font, left + Vector2(5, 6), "ZERO", HORIZONTAL_ALIGNMENT_LEFT, -1, ZERO_SIZE, 26, UI.INK)
	c.draw_string_outline(font, left, "ZERO", HORIZONTAL_ALIGNMENT_LEFT, -1, ZERO_SIZE, 15, neon)
	c.draw_string_outline(font, left, "ZERO", HORIZONTAL_ALIGNMENT_LEFT, -1, ZERO_SIZE, 6, UI.glow(UI.WHITE.lerp(UI.hue(0.1), 0.3), 1.6 * flicker))
	# Stroked as well as filled: it closes the seams where the font's shapes overlap.
	c.draw_string_outline(font, left, "ZERO", HORIZONTAL_ALIGNMENT_LEFT, -1, ZERO_SIZE, 2, UI.INK)
	c.draw_string(font, left, "ZERO", HORIZONTAL_ALIGNMENT_LEFT, -1, ZERO_SIZE, UI.INK)
	# The O's the clock: its hands race round to midnight, and start again.
	var o_w := UI.text_width(font, "O", ZERO_SIZE)
	var face := left + Vector2(w - o_w * 0.5, -ZERO_SIZE * 0.36)
	var minute := _time * 2.4 - PI * 0.5
	var hour := _time * 0.2 - PI * 0.5
	var hand := UI.glow(UI.YELLOW, 2.0 * flicker)
	c.draw_line(face, face + Vector2.from_angle(minute) * 13.0, hand, 3.5, true)
	c.draw_line(face, face + Vector2.from_angle(hour) * 8.0, hand, 3.5, true)


static func _noise(at: float) -> float:
	return fposmod(sin(at * 12.9898) * 43758.5453, 1.0)


## These layers all fill the logo: with no size of their own, they went missing for any
## frame the shake put the logo's corner above the screen.

## The chrome letters themselves, in their own shader.
class LogoSmask extends Control:
	var logo: Logo

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	func _draw() -> void:
		var font := UI.title_font()
		for i in Logo.SMASK.length():
			if not logo.letter_shown(i):
				continue
			draw_set_transform_matrix(logo.letter_transform(i))
			var at := Vector2(-logo.width_of(i) * 0.5, Logo.SIZE * 0.36)
			# A stroke too: it closes the hairline seams where the font's shapes overlap.
			draw_string_outline(font, at, Logo.SMASK[i], HORIZONTAL_ALIGNMENT_LEFT, -1, Logo.SIZE, 3)
			draw_string(font, at, Logo.SMASK[i], HORIZONTAL_ALIGNMENT_LEFT, -1, Logo.SIZE)
		draw_set_transform_matrix(Transform2D.IDENTITY)


## ZERO, over any letter knocked its way.
class LogoZero extends Control:
	var logo: Logo

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	func _draw() -> void:
		logo.draw_zero(self)
		draw_set_transform_matrix(Transform2D.IDENTITY)


## Over the letters: their white-hot flash when hit, and the ship, in its fat pixels.
class LogoTop extends Control:
	const SHIP_SCALE := 7.0
	var logo: Logo

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	func _draw() -> void:
		var font := UI.title_font()
		for i in Logo.SMASK.length():
			if logo.hit_of(i) > 0.0:
				draw_set_transform_matrix(logo.letter_transform(i))
				draw_string(font, Vector2(-logo.width_of(i) * 0.5, Logo.SIZE * 0.36), Logo.SMASK[i], HORIZONTAL_ALIGNMENT_LEFT, -1, Logo.SIZE, Color(UI.glow(UI.WHITE, 1.3), logo.hit_of(i) * 0.8))
		var flying := logo.flight()
		if flying == Logo.Flight.WAITING:
			return
		var word := logo.ship_transform()
		# What it's left burning through the letters, breathing a little.
		var ahead := Vector2(logo.surge() * Logo.SURGE, 0)
		var a := Vector2(Logo.TRAIL_FROM, 0)
		var b := Vector2(logo.trail_end, 0) + ahead
		if b.x > a.x:
			var breath := 1.0 + sin(logo.flame_time() * 5.0) * 0.1 + logo.surge() * 0.2
			draw_set_transform_matrix(word)
			UI.streak(self, a, b, 34.0 * breath, Color(UI.INK, 0.9))
			UI.streak(self, a, b, 24.0 * breath, UI.glow(UI.PINK, 1.5))
			UI.streak(self, a, b, 11.0 * breath, UI.glow(UI.WHITE, 1.8))
			# The pulse, running up it to the ship.
			if logo.pulse() >= 0.0:
				var head := lerpf(a.x, b.x, logo.pulse() * logo.pulse())
				UI.streak(self, Vector2(head - 150.0, 0), Vector2(head, 0), 15.0, UI.glow(UI.WHITE, 1.7))
		if logo.burst < 1.0:
			draw_set_transform_matrix(word * Transform2D(0.0, Vector2(logo.burst_x, 0)))
			var grown := UI.cubic_out(logo.burst)
			var left := 1.0 - logo.burst
			draw_circle(Vector2.ZERO, 40.0 + 90.0 * grown, Color(UI.glow(UI.YELLOW, 2.0), left * left * left * left * 0.8))
			draw_arc(Vector2.ZERO, 200.0 * grown, 0.0, TAU, 64, Color(UI.glow(UI.YELLOW, 2.4), left), 14.0 * left + 1.0, true)
		draw_set_transform_matrix(word * Transform2D(0.0, logo.ship_at + ahead))
		# Its engine: longer the faster it's going, ticking over when it's stopped.
		var flame := 26.0 + sin(logo.flame_time() * 37.0) * 7.0 + sin(logo.flame_time() * 61.0) * 5.0
		flame += minf(maxf(logo.ship_speed, 0.0) * 0.07, 400.0) + logo.surge() * 34.0
		UI.streak(self, Vector2(-44.0 - flame, 0), Vector2(-40, 0), 20.0, UI.glow(UI.WHITE, 2.0))
		var tex := Sprites.get_tex("ship3")
		draw_set_transform_matrix(word * Transform2D(PI * 0.5, Vector2(SHIP_SCALE, SHIP_SCALE), 0.0, logo.ship_at + ahead))
		draw_texture(tex, -tex.get_size() * 0.5)
		draw_set_transform_matrix(Transform2D.IDENTITY)
