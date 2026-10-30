class_name Missiles
extends RefCounted
## The original's homing bullets, kept in packed arrays because there are a lot
## of them: a hard shove along where it points, drag, a quick turn to its target,
## and so they swing about, overshoot and come back, as they did.

var world: World
var count := 0
var positions := PackedVector2Array()
var velocities := PackedVector2Array()
var angles := PackedFloat32Array()
var lives := PackedFloat32Array()
var damages := PackedFloat32Array()
var targets: Array[Enemy] = []
var _lines := PackedVector2Array()
var _hot_lines := PackedVector2Array()
var _heads := PackedVector2Array()


func _init(the_world: World) -> void:
	world = the_world
	positions.resize(Balance.MISSILE_LIMIT)
	velocities.resize(Balance.MISSILE_LIMIT)
	angles.resize(Balance.MISSILE_LIMIT)
	lives.resize(Balance.MISSILE_LIMIT)
	damages.resize(Balance.MISSILE_LIMIT)
	targets.resize(Balance.MISSILE_LIMIT)


func launch(ship: Ship, target: Enemy) -> void:
	if count >= Balance.MISSILE_LIMIT:
		return
	var i := count
	count += 1
	var rng := world.rng
	# Out of the tubes on either side, flung wide before they turn.
	var side := -1.0 if rng.randf() < 0.5 else 1.0
	var kick_angle := ship.angle + side * rng.randf_range(0.7, 1.9)
	positions[i] = ship.pos + Vector2.from_angle(ship.angle + side * PI * 0.5) * 4.0
	velocities[i] = ship.vel * Balance.MISSILE_INHERIT + Vector2.from_angle(kick_angle) * Balance.MISSILE_KICK
	angles[i] = kick_angle
	lives[i] = Balance.MISSILE_LIFE
	var run := world.run
	damages[i] = Balance.MISSILE_DAMAGE * (1.0 + Balance.SPEED_DAMAGE * ship.speed_fraction()) * (1.0 + run.level("warhead") / 3.0)
	targets[i] = target


## A missile for everything out there, at once.
func salvo_all(ship: Ship) -> void:
	for target in world.targets:
		launch(ship, target)


func step(dt: float) -> void:
	var drag_factor := exp(-Balance.DRAG * dt)
	var run := world.run
	var turn := clampf(dt * Balance.MISSILE_TURN * (1.5 if run.has("track") else 1.0), 0.0, 1.0)
	var ghost := run.has("track")
	var arena: Rect2 = world.arena
	var i := 0
	while i < count:
		lives[i] -= dt
		if lives[i] <= 0.0:
			world.fx.spark_at(positions[i], Color("9badb7"))
			_remove(i)
			continue
		var target := targets[i]
		if target == null or not target.alive or not target.targetable:
			target = world.random_target()
			targets[i] = target
		var p := positions[i]
		var v := velocities[i]
		var a := angles[i]
		if target != null:
			var to := target.pos - p
			a = lerp_angle(a, atan2(to.y, to.x), turn)
		angles[i] = a
		v += Vector2(cos(a), sin(a)) * Balance.MISSILE_THRUST * dt
		v *= drag_factor
		var next := p + v * dt
		if not ghost and not arena.has_point(next):
			# The original's: gone at the wall.
			world.fx.spark_at(next.clamp(arena.position, arena.end), Color("fbf236"))
			_remove(i)
			continue
		var hit := world.grid_hit(p, next)
		if hit != null:
			_hit(i, hit, next)
			continue
		positions[i] = next
		velocities[i] = v
		i += 1


func _hit(i: int, enemy: Enemy, at: Vector2) -> void:
	var amount := damages[i]
	enemy.damage(amount, "missile")
	world.fx.hit_spark(at, velocities[i], world.rng)
	world.sfx("hit", -15.0, world.rng.randf_range(0.85, 1.25))
	var frag := world.run.level("frag")
	if frag > 0:
		world.splash(at, 12.0 + 6.0 * frag, amount * (0.3 + 0.2 * frag), enemy)
	_remove(i)


func _remove(i: int) -> void:
	count -= 1
	positions[i] = positions[count]
	velocities[i] = velocities[count]
	angles[i] = angles[count]
	lives[i] = lives[count]
	damages[i] = damages[count]
	targets[i] = targets[count]
	targets[count] = null


func clear() -> void:
	for i in count:
		targets[i] = null
	count = 0


func draw(canvas: CanvasItem) -> void:
	_lines.resize(0)
	_hot_lines.resize(0)
	_heads.resize(0)
	var hot_from := Balance.MISSILE_DAMAGE * (1.0 + Balance.SPEED_DAMAGE * 0.6)
	for i in count:
		var p := positions[i].round()
		var tail := (positions[i] - velocities[i] * 0.022).round()
		if damages[i] >= hot_from:
			_hot_lines.append(p)
			_hot_lines.append(tail)
		else:
			_lines.append(p)
			_lines.append(tail)
	if not _lines.is_empty():
		canvas.draw_multiline(_lines, Color("5fcde4"))
	if not _hot_lines.is_empty():
		canvas.draw_multiline(_hot_lines, Color("fbf236"))
	for i in count:
		canvas.draw_rect(Rect2(positions[i].round(), Vector2.ONE), Color.WHITE)
