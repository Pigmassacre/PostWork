extends Enemy
## 00:00, OVERTIME. The clock itself, in the middle of the floor. Its twelve
## numbers are twelve targets, going round it, and its hands are lethal: they
## sweep the floor. When the numbers are gone the face is all that's left, and it
## stops pretending. The count on the floor is the numbers, then the face: it
## ends, of course, on zero.

const RING := 84.0
const FACE_RADIUS := 26.0
const HAND_WIDTH := 3.0

var numbers: Array[Enemy] = []
var _turn := -PI * 0.5
var _hour_hand := -PI * 0.5
var _minute_hand := -PI * 0.5
var _second_hand := PI
var _live := 0.0
var _strike_clock := 5.0
var _spiral := 0.0
var _spiral_clock := 0.0
var _add_clock := 7.0
var _exposed := false
var _chimes := 0


class Numeral extends Enemy:
	var boss: Enemy
	var number := 12

	func is_boss_part() -> bool:
		return true

	func step(dt: float) -> void:
		age += dt
		flash = maxf(flash - dt * 7.0, 0.0)

	func on_death() -> void:
		boss.call("number_lost", self)

	func tex() -> Texture2D:
		return null

	func draw_shadow(_c: CanvasItem) -> void:
		pass

	func draw(c: CanvasItem) -> void:
		var font := UI.pixel_font()
		var text := str(number)
		var size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
		var at := (pos + Vector2(-size.x * 0.5, 16 * 0.4)).round()
		c.draw_string(font, at + Vector2(1, 2), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0, 0, 0, 0.5))
		var color := Color.WHITE if flash > 0.3 else Color("fbf236").lerp(Color("d95763"), 1.0 - hp / max_hp)
		for offset: Vector2 in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
			c.draw_string(font, at + offset, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.BLACK)
		c.draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, color)

	func draw_flash(_c: CanvasItem) -> void:
		pass


func enter() -> void:
	kind = "overtime"
	var toughness := world.run.toughness()
	max_hp = 1300.0 * toughness
	hp = max_hp
	radius = FACE_RADIUS
	score = 20000
	coins = 50
	pushy = false
	walled = false
	targetable = false
	drag = 0.0
	turn = 0.0
	pos = Vector2.ZERO
	world.remaining = 0
	for i in 12:
		var n := Numeral.new()
		n.world = world
		n.kind = "numeral"
		n.boss = self
		n.number = 12 if i == 0 else i
		n.max_hp = 70.0 * toughness
		n.hp = n.max_hp
		n.radius = 8.0
		n.score = 800
		n.coins = 3
		n.pushy = false
		n.walled = false
		numbers.append(n)
		world.add_enemy(n)
	_place_numbers()
	world.add_enemy(self)
	_live = -2.0
	world.sfx("bell", 0.0)


func is_boss_part() -> bool:
	return true


func _place_numbers() -> void:
	for n: Enemy in numbers:
		var slot: int = n.get("number") % 12
		var at := _turn + PI * 0.5 + TAU * slot / 12.0 - PI * 0.5
		n.pos = pos + Vector2(cos(at) * RING * 1.5, sin(at) * RING)


func step(dt: float) -> void:
	age += dt
	flash = maxf(flash - dt * 7.0, 0.0)
	_live += dt
	var rage := 1.0 - float(numbers.size()) / 12.0
	_turn += dt * lerpf(0.12, 0.28, rage)
	_place_numbers()
	var pace := 1.0 if _live > 0.0 else 0.15
	if _exposed:
		_minute_hand += dt * 1.15 * pace
		_hour_hand -= dt * 0.55 * pace
		_second_hand += dt * 2.3 * pace
	else:
		_minute_hand += dt * lerpf(0.42, 0.8, rage) * pace
		_hour_hand += dt * lerpf(0.14, 0.26, rage) * pace
	if _live > 0.0:
		_hands_hurt()
		_attack(dt, rage)


func _hand_end(angle_now: float, length: float) -> Vector2:
	return pos + Vector2.from_angle(angle_now) * length


func _hands_hurt() -> void:
	var ship := world.ship
	for h: Array in _hands():
		var a: Vector2 = pos
		var b: Vector2 = _hand_end(h[0], h[1])
		var ab := b - a
		var t := clampf((ship.pos - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
		if (a + ab * t).distance_to(ship.pos) < HAND_WIDTH + Balance.SHIP_RADIUS - 1.0:
			if ship.is_smasking():
				continue
			ship.hurt(a + ab * t)


## For the autopilot: the hands, as lines.
func hazards() -> Array:
	var lines := []
	for h: Array in _hands():
		lines.append([pos, _hand_end(h[0], h[1])])
	return lines


## Each hand: its angle, its length, its colour.
func _hands() -> Array:
	var long := 300.0
	var hands := [[_minute_hand, long, Color("d95763")], [_hour_hand, 150.0, Color("df7126")]]
	if _exposed:
		hands.append([_second_hand, 110.0, Color("fbf236")])
	return hands


func _attack(dt: float, rage: float) -> void:
	_strike_clock -= dt
	if _strike_clock <= 0.0 and not numbers.is_empty():
		_strike_clock = lerpf(5.0, 2.8, rage)
		# The hour strikes: the numbers all fire.
		_chimes += 1
		world.sfx("bell", -6.0, 1.0 + rage * 0.3)
		for n: Enemy in numbers:
			world.shots.fire(n.pos, (world.ship.pos - n.pos).normalized() * 70.0, "shot_round")
	if numbers.is_empty():
		_spiral_clock -= dt
		if _spiral_clock <= 0.0:
			_spiral_clock = 0.28
			_spiral += 0.5
			world.shots.ring(pos, 4, 62.0, "shot_small", _spiral, 0.2)
			world.sfx("shot", -14.0, 0.9)
	_add_clock -= dt
	if _add_clock <= 0.0:
		_add_clock = 6.0 if not _exposed else 4.5
		for i in 3:
			world.add_kind("tadpole", pos + Vector2.from_angle(world.rng.randf() * TAU) * (FACE_RADIUS + 6.0))


func number_lost(n: Enemy) -> void:
	numbers.erase(n)
	world.sfx("bell", -8.0, 1.2)
	if numbers.is_empty():
		_expose()


func _expose() -> void:
	_exposed = true
	targetable = true
	flash = 1.0
	_second_hand = _minute_hand + PI
	world.fx.flash(Color("d95763"), 0.6)
	world.fx.shake(10.0)
	world.fx.ripple(pos, 1.0)
	world.fx.ring(pos, 200.0, 0.6, Color("d95763"))
	world.shots.ring(pos, 24, 80.0, "shot_round")
	world.sfx("bell", 2.0, 0.7)
	world.say_word("FACE EXPOSED", Color("d95763"))


func on_death() -> void:
	world.fx.flash(Color.WHITE, 1.0)
	for i in 8:
		world.fx.ring(pos, 40.0 + i * 40.0, 0.4 + i * 0.12, Color("fbf236"))
	world.fx.burst(pos, Color("fbf236"), 60, 380.0, world.rng)
	world.sfx("bell", 4.0, 0.6)


func tex() -> Texture2D:
	return null


func draw_shadow(c: CanvasItem) -> void:
	c.draw_circle((pos + Vector2(2, 4)).round(), FACE_RADIUS + 2.0, Color(0, 0, 0, 0.35))


func draw_under(c: CanvasItem) -> void:
	# The hands go under the things they're after, but over the floor.
	var warned := _live <= 0.0
	for h: Array in _hands():
		var color: Color = h[2]
		if warned:
			color.a = 0.25 + 0.2 * sin(age * 12.0)
		var end := _hand_end(h[0], h[1]).clamp(world.arena.position - Vector2(60, 60), world.arena.end + Vector2(60, 60))
		var clip := _clip_to_arena(pos, end)
		c.draw_line(pos.round(), clip.round(), Color(0, 0, 0, 0.5 * color.a), 5.0)
		c.draw_line(pos.round(), clip.round(), color, 3.0)
		c.draw_line(pos.round(), clip.round(), Color(1, 1, 1, 0.7 * color.a), 1.0)


func _clip_to_arena(from: Vector2, to: Vector2) -> Vector2:
	var arena: Rect2 = world.arena
	var t := 1.0
	var d := to - from
	if d.x > 0.0:
		t = minf(t, (arena.end.x - from.x) / d.x)
	elif d.x < 0.0:
		t = minf(t, (arena.position.x - from.x) / d.x)
	if d.y > 0.0:
		t = minf(t, (arena.end.y - from.y) / d.y)
	elif d.y < 0.0:
		t = minf(t, (arena.position.y - from.y) / d.y)
	return from + d * clampf(t, 0.0, 1.0)


func draw(c: CanvasItem) -> void:
	var at := pos.round()
	c.draw_circle(at, FACE_RADIUS + 2.0, Color.BLACK)
	var face := Color("cbdbfc") if not _exposed else Color("d95763").lerp(Color("cbdbfc"), hp / max_hp)
	c.draw_circle(at, FACE_RADIUS, face)
	c.draw_circle(at, FACE_RADIUS - 3.0, Color("222034") if _exposed else Color("3f3f74"))
	for i in 12:
		var dir := Vector2.from_angle(TAU * i / 12.0)
		c.draw_rect(Rect2((at + dir * (FACE_RADIUS - 5.0)).round() - Vector2.ONE, Vector2(2, 2)), face)
	# It watches you.
	var look := to_ship().normalized() * 3.0
	for side: float in [-8.0, 8.0]:
		c.draw_rect(Rect2((at + Vector2(side - 3.0, -5.0)).round(), Vector2(6, 6)), Color.WHITE)
		c.draw_rect(Rect2((at + Vector2(side - 1.0, -3.0) + look).round(), Vector2(3, 3)), Color.BLACK)
	var mouth := Rect2(at + Vector2(-8, 7), Vector2(16, 2 if not _exposed else 5))
	c.draw_rect(mouth, Color("d95763") if _exposed else Color.BLACK)


func draw_flash(c: CanvasItem) -> void:
	if flash > 0.0:
		c.draw_circle(pos.round(), FACE_RADIUS, Color(1, 1, 1, flash * 0.8))
