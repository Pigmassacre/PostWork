class_name Autopilot
extends RefCounted
## Flies the ship by itself: for the title's demo, and for testing without a
## player (`--autoplay`). Keeps moving, keeps off the walls, goes round what's
## close and through the coins, and smasks what's got a shell on.

var world: World
var steer := Vector2.ZERO
var smask := false
var _wander := Vector2.RIGHT
var _wander_clock := 0.0
var _charge_clock := 0.0
var _boredom := 0.0


func _init(the_world: World) -> void:
	world = the_world


func think(dt: float) -> void:
	var ship := world.ship
	var push := Vector2.ZERO
	var closest := INF
	var nearest: Enemy = null
	var shell: Enemy = null
	# It has a lot of momentum: what matters is where it and they'll be in a moment.
	var soon := ship.pos + ship.vel * 0.25
	for e in world.enemies:
		if not e.alive:
			continue
		var d := soon - (e.pos + e.vel * 0.25)
		var dist := d.length()
		var clear := dist - e.radius
		if e.harmful and clear < 70.0 and dist > 0.01:
			push += d / dist * (70.0 - clear) * 0.12
		if clear < closest:
			closest = clear
			nearest = e
		if e.shelled and (shell == null or dist < ship.pos.distance_to(shell.pos)):
			shell = e
	for s in world.shots.list:
		var d: Vector2 = soon - s.pos
		var dist := d.length()
		if dist < 40.0 and dist > 0.01:
			# Across its way, not back along it.
			var across: Vector2 = s.vel.orthogonal().normalized()
			push += across * signf(across.dot(d) + 0.01) * (40.0 - dist) * 0.14
	push += _avoid_hands(soon)
	# The walls push back.
	var inner: Rect2 = world.arena.grow(-30.0)
	var wall := Vector2.ZERO
	wall.x = minf(soon.x - inner.position.x, 0.0) + maxf(soon.x - inner.end.x, 0.0)
	wall.y = minf(soon.y - inner.position.y, 0.0) + maxf(soon.y - inner.end.y, 0.0)
	push -= wall * 0.09
	for b in world.bumpers:
		var d: Vector2 = ship.pos - b.pos
		if d.length() < 30.0:
			push += d.normalized() * 0.5
	# Coins, if it's quiet enough.
	if closest > 38.0:
		var best := 90.0
		for p in world.pickups.list:
			var dist: float = ship.pos.distance_to(p.pos)
			if dist < best:
				best = dist
				push += (p.pos - ship.pos).normalized() * 0.4
	_wander_clock -= dt
	if _wander_clock <= 0.0:
		_wander_clock = world.rng.randf_range(0.6, 1.4)
		_wander = Vector2.from_angle(world.rng.randf() * TAU)
	var goal := push + _wander * 0.35
	steer = goal.normalized() if goal.length() > 0.05 else ship.vel.normalized()
	_think_smask(dt, ship, shell, nearest, closest)


## Keeps clear of what's lethal and not a thing: the clock's hands.
func _avoid_hands(soon: Vector2) -> Vector2:
	var away := Vector2.ZERO
	var hazards: Array = world.boss.call("hazards") if world.boss != null and world.boss.has_method("hazards") else []
	for line: Array in hazards:
		var a: Vector2 = line[0]
		var ab: Vector2 = line[1] - a
		var at: Vector2 = a + ab * clampf((soon - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
		var d := soon - at
		if d.length() < 34.0:
			away += d.normalized() * (34.0 - d.length()) * 0.2
	return away


func _think_smask(dt: float, ship: Ship, shell: Enemy, nearest: Enemy, closest: float) -> void:
	if ship.state == Ship.State.CHARGING:
		_charge_clock -= dt
		var target := shell if shell != null else nearest
		if target != null:
			steer = (target.pos - ship.pos).normalized()
		smask = _charge_clock > 0.0
		return
	if ship.state == Ship.State.SMASKING:
		smask = false
		return
	smask = false
	_boredom += dt
	var wants := false
	if shell != null and closest > 42.0 and ship.pos.distance_to(shell.pos) < 120.0 and ship.cooldown <= 0.0:
		wants = true
	elif nearest != null and closest > 42.0 and closest < 90.0 and _boredom > 4.0 and ship.cooldown <= 0.0:
		wants = true
	if wants:
		smask = true
		_boredom = 0.0
		_charge_clock = world.rng.randf_range(0.3, 0.75)
