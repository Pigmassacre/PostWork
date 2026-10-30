class_name Ship
extends RefCounted
## The player: the original's ship and how it flew, a turn and a shove and a lot
## of drift. The guns take care of themselves. Holding the SMASK stops them and
## brakes the ship, as charging did in the original; letting go throws it, and
## whatever's in the way, at whatever's in front of it.

enum State { FLYING, CHARGING, SMASKING, DEAD }

var world: World
var run: Run
var pos := Vector2.ZERO
var vel := Vector2.ZERO
## Where it points, and where it wants to.
var angle := -PI * 0.5
var desired_angle := -PI * 0.5
var state := State.FLYING
var charge := 0.0
var charge_time := 0.0
var cooldown := 0.0
var invulnerable := 0.0
var smask_left := 0.0
var smask_power := 0.0
var smask_dir := Vector2.UP
## Which SMASK this is, so a thing is only hit once by each.
var smask_id := 0
var salvo_clock := 0.0
var robin := 0
var thrusting := 0.0
var flame_time := 0.0
var wall_sound_clock := 0.0
var auto: Autopilot


func _init(the_world: World, the_run: Run) -> void:
	world = the_world
	run = the_run


func top_speed() -> float:
	return Balance.THRUST * thrust_factor() / drag()


func thrust_factor() -> float:
	return 1.0 + 0.25 * run.level("burn")


func drag() -> float:
	return Balance.DRAG * pow(0.67, run.level("slick"))


func speed_fraction() -> float:
	return clampf(vel.length() / top_speed(), 0.0, 1.0)


func is_smasking() -> bool:
	return state == State.SMASKING


func can_be_hurt() -> bool:
	return state != State.SMASKING and state != State.DEAD and invulnerable <= 0.0


func step(dt: float) -> void:
	if state == State.DEAD:
		return
	var steering := Vector2.ZERO
	var held := false
	var thrust := 0.0
	if auto:
		auto.think(dt)
		steering = auto.steer
		held = auto.smask
		thrust = 1.0 if steering != Vector2.ZERO else 0.0
	elif world.controls_live():
		steering = Inputs.steer(world.to_screen(pos), world.pointer())
		held = Inputs.smask_held()
		thrust = Inputs.thrust(steering)
	if steering.length() > Balance.STICK_DEADZONE:
		desired_angle = steering.angle()
	angle = lerp_angle(angle, desired_angle, clampf(dt * Balance.TURN, 0.0, 1.0))
	thrusting = thrust
	invulnerable = maxf(invulnerable - dt, 0.0)
	cooldown = maxf(cooldown - dt, 0.0)
	wall_sound_clock = maxf(wall_sound_clock - dt, 0.0)
	match state:
		State.FLYING:
			vel += Vector2.from_angle(angle) * Balance.THRUST * thrust_factor() * thrust * dt
			vel *= exp(-drag() * dt)
			if held and cooldown <= 0.0:
				_start_charge()
			elif not held:
				_fire(dt)
		State.CHARGING:
			_charge(dt, held)
		State.SMASKING:
			_smask(dt)
	pos += vel * dt
	_walls()
	if thrust > 0.0 and state == State.FLYING and world.rng.randf() < dt * 40.0:
		world.fx.puff(pos - Vector2.from_angle(angle) * 8.0, -Vector2.from_angle(angle) * 50.0 + vel * 0.6, world.rng)


func _start_charge() -> void:
	state = State.CHARGING
	charge = 0.0
	charge_time = 0.0
	world.sfx("charge", -6.0)


func _charge(dt: float, held: bool) -> void:
	charge_time += dt
	var was := charge
	charge = minf(charge + dt / (Balance.CHARGE_TIME * pow(0.6, run.level("fuse"))), 1.0)
	if charge >= 1.0 and was < 1.0:
		world.sfx("charged", -4.0)
		world.fx.ring(pos, 22.0, 0.25, Color("fbf236"))
	# The original's slowdown, got to fast.
	var speed := vel.length()
	if speed > Balance.CHARGE_SPEED_LIMIT:
		vel = vel.normalized() * maxf(Balance.CHARGE_SPEED_LIMIT, speed * exp(-Balance.CHARGE_BRAKE * dt))
	if not held:
		if charge >= Balance.CHARGE_MIN:
			_let_go()
		else:
			state = State.FLYING
			charge = 0.0


func _let_go() -> void:
	state = State.SMASKING
	smask_id += 1
	smask_power = charge
	charge = 0.0
	var long := 1.0 + 0.3 * run.level("long")
	smask_left = lerpf(Balance.SMASK_TIME_MIN, Balance.SMASK_TIME_MAX, smask_power) * long
	smask_dir = Vector2.from_angle(desired_angle)
	angle = desired_angle
	vel = smask_dir * lerpf(Balance.SMASK_SPEED_MIN, Balance.SMASK_SPEED_MAX, smask_power)
	world.sfx("smask", -2.0 + smask_power * 2.0, 0.9 + smask_power * 0.25)
	world.fx.shake(2.5 + smask_power * 3.0)
	world.fx.ring(pos, 18.0 + 16.0 * smask_power, 0.22, Color("fbf236"))
	world.fx.ripple(pos, 0.5 * smask_power + 0.25)
	world.rumble(0.3 + smask_power * 0.3)
	if run.has("echo"):
		world.missiles.salvo_all(self)


func _smask(dt: float) -> void:
	smask_left -= dt
	if world.rng.randf() < 0.9:
		world.fx.streak(pos, vel, world.rng)
	if smask_left <= 0.0:
		_end_smask()


func _end_smask() -> void:
	state = State.FLYING
	cooldown = Balance.SMASK_COOLDOWN
	invulnerable = maxf(invulnerable, Balance.SMASK_GRACE)
	# It carries on at what it would fly at, flat out. The drift's the prize.
	vel = vel.normalized() * minf(vel.length(), top_speed())
	if run.has("shock"):
		var factor := 0.6 + 0.3 * run.level("shock")
		world.shock(pos, lerpf(Balance.WALL_SHOCK_RADIUS_MIN, Balance.WALL_SHOCK_RADIUS_MAX, smask_power) * factor,
			lerpf(Balance.WALL_SHOCK_DAMAGE_MIN, Balance.WALL_SHOCK_DAMAGE_MAX, smask_power) * factor)


## What the SMASK does to what it hits.
func smask_damage() -> float:
	var long := 1.0 + 0.3 * run.level("long")
	return lerpf(Balance.SMASK_DAMAGE_MIN, Balance.SMASK_DAMAGE_MAX, smask_power) * long


## A kill with the SMASK: it can go again straight away.
func on_smask_kill() -> void:
	cooldown = 0.0


func _fire(dt: float) -> void:
	salvo_clock -= dt
	if salvo_clock > 0.0:
		return
	var targets := world.targets
	if targets.is_empty():
		return
	salvo_clock = Balance.SALVO_TIME
	var width := Balance.SALVO_WIDTH + run.level("twin")
	# The whole salvo goes out, however few there are to share it.
	for i in width:
		robin = (robin + 1) % targets.size()
		world.missiles.launch(self, targets[robin])
	world.sfx("fire", -14.0, world.rng.randf_range(0.9, 1.15))


func _walls() -> void:
	var inside: Rect2 = world.arena.grow(-Balance.SHIP_RADIUS - 1.0)
	var hit := Vector2.ZERO
	if pos.x < inside.position.x:
		pos.x = inside.position.x
		hit.x = 1.0
	elif pos.x > inside.end.x:
		pos.x = inside.end.x
		hit.x = -1.0
	if pos.y < inside.position.y:
		pos.y = inside.position.y
		hit.y = 1.0
	elif pos.y > inside.end.y:
		pos.y = inside.end.y
		hit.y = -1.0
	if hit == Vector2.ZERO:
		return
	var into := absf(vel.dot(hit.normalized()))
	if state == State.SMASKING:
		_wall_smask(hit)
	elif run.has("bumper"):
		vel = vel.bounce(hit.normalized()) * 0.9
		if into > 40.0:
			world.fx.ring(pos, 10.0, 0.15, Color("99e550"))
			world.sfx("bump", -8.0)
	else:
		# The original's: stopped across, sliding along.
		if hit.x != 0.0:
			vel.x = 0.0
		if hit.y != 0.0:
			vel.y = 0.0
		if into > 120.0 and wall_sound_clock <= 0.0:
			wall_sound_clock = 0.2
			world.sfx("wall", -10.0 + into / 100.0)
			world.fx.shake(minf(into / 200.0, 1.5))
			world.fx.sparks(pos - hit * 4.0, hit, 5, world.rng)


func _wall_smask(normal: Vector2) -> void:
	var radius := lerpf(Balance.WALL_SHOCK_RADIUS_MIN, Balance.WALL_SHOCK_RADIUS_MAX, smask_power)
	var damage := lerpf(Balance.WALL_SHOCK_DAMAGE_MIN, Balance.WALL_SHOCK_DAMAGE_MAX, smask_power)
	if run.has("shock"):
		radius *= 1.3
	vel = vel.bounce(normal.normalized()) * Balance.WALL_BOUNCE
	desired_angle = vel.angle()
	angle = desired_angle
	world.shock(pos, radius, damage)
	world.fx.shake(4.0 + smask_power * 5.0)
	world.fx.hitstop(0.05 + smask_power * 0.05)
	world.fx.wall_hit = 1.0
	world.sfx("wall_smask", -2.0)
	world.rumble(0.6 + smask_power * 0.4)
	_end_smask()


## Something's got to it. Returns true if that did any harm.
func hurt(from: Vector2) -> bool:
	if not can_be_hurt() or world.is_invincible():
		return false
	run.hull -= 1
	run.hits_this_hour += 1
	run.combo /= 2
	state = State.FLYING if state != State.DEAD else state
	charge = 0.0
	invulnerable = Balance.INVULNERABLE_AFTER_HIT
	vel += (pos - from).normalized() * 200.0
	world.fx.shake(8.0)
	world.fx.hitstop(0.14)
	world.fx.flash(Color("ac3232"), 0.5)
	world.fx.ripple(pos, 1.0)
	world.fx.ring(pos, Balance.HIT_SHOVE_REACH, 0.3, Color("d95763"))
	world.fx.burst(pos, Color("639bff"), 18, 170.0, world.rng)
	world.sfx("hurt")
	world.rumble(1.0)
	world.shove_from(pos, Balance.HIT_SHOVE_REACH, Balance.HIT_SHOVE)
	if run.hull <= 0:
		if run.has("second") and not run.second_wind_used:
			run.second_wind_used = true
			run.hull = 1
			invulnerable = Balance.INVULNERABLE_AFTER_HIT * 2.0
			world.sfx("coffee", 0.0, 0.7)
			world.say_word("SECOND WIND", Color("d95763"))
		else:
			_die()
	return true


func _die() -> void:
	state = State.DEAD
	world.on_ship_dead()


## Which of the original's four frames: engine off, or its three flames.
func frame() -> int:
	if thrusting <= 0.0 and state != State.SMASKING:
		return 1
	return 2 + int(flame_time * 18.0) % 3


func draw(canvas: CanvasItem) -> void:
	if state == State.DEAD:
		return
	flame_time += canvas.get_process_delta_time()
	if invulnerable > 0.0 and state == State.FLYING and int(invulnerable * 16.0) % 2 == 0:
		return
	var tex := Sprites.get_tex("ship%d" % frame())
	var rot := angle + PI * 0.5
	Sprites.draw(canvas, tex, pos, rot)
	if state == State.CHARGING:
		_draw_charge(canvas)


func _draw_charge(canvas: CanvasItem) -> void:
	# Where it's going to go, and how far.
	var dir := Vector2.from_angle(desired_angle)
	var long := 1.0 + 0.3 * run.level("long")
	var reach := lerpf(Balance.SMASK_SPEED_MIN * Balance.SMASK_TIME_MIN, Balance.SMASK_SPEED_MAX * Balance.SMASK_TIME_MAX, charge) * long
	var color := Color("fbf236") if charge >= 1.0 else Color("cbdbfc", 0.8)
	var at := 12.0
	var dash := 0
	while at < reach:
		var p := pos + dir * at
		if dash % 2 == 0 and world.arena.has_point(p):
			canvas.draw_rect(Rect2(p.round(), Vector2.ONE), color)
		at += 4.0
		dash += 1
	canvas.draw_arc(pos.round(), 11.0, -PI * 0.5, -PI * 0.5 + TAU * charge, 20, color, 1.0)
