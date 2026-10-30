extends Enemy
## 19:00, THE COMMUTE. A train: the head steers for you with a turning circle, and
## the carriages run along behind it on the rails it's laid. Each is a target of
## its own, and each lets out a few passengers when it goes. When they've all
## gone the head's fair game, and it's running late.

const CARS := 10
const SPACING := 13.0
const TRAIL_STEP := 2.0
const CRUISE := 120.0
const EXPRESS := 280.0

var cars: Array[Enemy] = []
var _trail := PackedVector2Array()
var _trail_gap := 0.0
var _heading := 0.0
var _speed := CRUISE
var _plan := 0.0
var _express_left := 0.0
var _aim_left := 0.0
var _aim_angle := 0.0


class Car extends Enemy:
	var train: Enemy
	var index := 0

	func is_boss_part() -> bool:
		return true

	func step(dt: float) -> void:
		age += dt
		flash = maxf(flash - dt * 7.0, 0.0)
		clock -= dt
		if clock <= 0.0:
			clock = world.rng.randf_range(4.0, 6.5)
			# A window opens.
			var side := Vector2.from_angle(angle).orthogonal() * (1.0 if world.rng.randf() < 0.5 else -1.0)
			world.shots.fire(pos, side * 70.0, "shot_round")
		vel = Vector2.ZERO

	func on_death() -> void:
		train.call("car_lost", self)

	func tex() -> Texture2D:
		return Sprites.get_tex("train_car_hurt" if hp < max_hp * 0.5 else "train_car")

	func draw_rotation() -> float:
		return angle + PI * 0.5


func enter() -> void:
	kind = "commute"
	sprite = "train_head"
	var toughness := world.run.toughness()
	max_hp = 220.0 * toughness
	hp = max_hp
	radius = 7.0
	score = 3000
	coins = 20
	pushy = false
	walled = false
	targetable = false
	drag = 0.0
	turn = 0.0
	pos = Vector2(world.arena.position.x - 30.0, world.arena.position.y + 40.0)
	_heading = 0.3
	for i in CARS:
		var car := Car.new()
		car.world = world
		car.kind = "car"
		car.sprite = "train_car"
		car.train = self
		car.index = i
		car.max_hp = 45.0 * toughness
		car.hp = car.max_hp
		car.radius = 6.0
		car.score = 300
		car.coins = 3
		car.pushy = false
		car.walled = false
		car.clock = world.rng.randf_range(2.0, 6.0)
		car.pos = pos
		cars.append(car)
		world.add_enemy(car)
	world.add_enemy(self)
	world.remaining -= 1 if world.remaining > CARS + 1 else 0
	world.remaining = CARS + 1
	world.total = world.remaining
	# Rails laid back the way it came, for the carriages to come in on.
	for i in 300:
		_trail.append(pos - Vector2.from_angle(_heading) * i * TRAIL_STEP)
	_plan = 2.5


func is_boss_part() -> bool:
	return true


func step(dt: float) -> void:
	age += dt
	flash = maxf(flash - dt * 7.0, 0.0)
	_steer(dt)
	pos += Vector2.from_angle(_heading) * _speed * dt
	angle = _heading
	_trail_gap += _speed * dt
	while _trail_gap >= TRAIL_STEP:
		_trail_gap -= TRAIL_STEP
		_trail.insert(0, pos)
		if _trail.size() > 400:
			_trail.resize(400)
	for i in cars.size():
		var car: Enemy = cars[i]
		var at := clampi(int((i + 1) * SPACING / TRAIL_STEP), 0, _trail.size() - 2)
		car.pos = _trail[at]
		car.angle = (_trail[at] - _trail[at + 1]).angle()


func _steer(dt: float) -> void:
	var arena: Rect2 = world.arena
	var to_goal := world.ship.pos - pos
	var turn_rate := 1.3
	if _express_left > 0.0:
		_express_left -= dt
		_speed = move_toward(_speed, EXPRESS, 500.0 * dt)
		turn_rate = 0.25
		if world.rng.randf() < 0.6:
			world.fx.puff(pos, -Vector2.from_angle(_heading) * 30.0, world.rng)
	elif _aim_left > 0.0:
		_aim_left -= dt
		_speed = move_toward(_speed, 40.0, 300.0 * dt)
		_aim_angle = to_goal.angle()
		_heading = lerp_angle(_heading, _aim_angle, clampf(dt * 3.0, 0.0, 1.0))
		if _aim_left <= 0.0:
			_express_left = 1.5
			world.sfx("horn", 0.0)
			world.fx.shake(3.0)
		return
	else:
		_speed = move_toward(_speed, CRUISE * (1.2 if cars.is_empty() else 1.0), 200.0 * dt)
		_plan -= dt
		if _plan <= 0.0:
			_plan = world.rng.randf_range(4.5, 6.5) * (0.85 if cars.is_empty() else 1.0)
			_aim_left = 1.0
			world.sfx("warning", -6.0)
	# Back into the floor if it's about to leave it.
	var ahead := pos + Vector2.from_angle(_heading) * 40.0
	if not arena.grow(-14.0).has_point(ahead):
		to_goal = -pos
		turn_rate = 3.2
	_heading = rotate_toward(_heading, to_goal.angle(), turn_rate * dt)


func car_lost(car: Enemy) -> void:
	cars.erase(car)
	world.add_kind("tadpole", car.pos)
	if cars.is_empty():
		targetable = true
		world.say_word("THE LAST CARRIAGE", Color("fbf236"))
		world.sfx("horn")


func tex() -> Texture2D:
	return Sprites.get_tex("train_head")


func draw_rotation() -> float:
	return _heading + PI * 0.5


func draw_under(c: CanvasItem) -> void:
	if _aim_left > 0.0 and int(_aim_left * 14.0) % 2 == 0:
		var dir := Vector2.from_angle(_heading)
		var at := 10.0
		while at < 240.0:
			var p := pos + dir * at
			if world.arena.has_point(p):
				c.draw_rect(Rect2(p.round(), Vector2(2, 2)), Color("d95763"))
			at += 7.0
