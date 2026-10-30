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
	for e in world.enemies:
		if not e.alive:
			continue
		var d := ship.pos - e.pos
		var dist := d.length()
		var clear := dist - e.radius
		if e.harmful and clear < 58.0 and dist > 0.01:
			push += d / dist * (58.0 - clear) * 0.09
		if clear < closest:
			closest = clear
			nearest = e
		if e.shelled and (shell == null or dist < ship.pos.distance_to(shell.pos)):
			shell = e
	for s in world.shots.list:
		var d: Vector2 = ship.pos - s.pos
		var dist := d.length()
		if dist < 40.0 and dist > 0.01:
			# Across its way, not back along it.
			var across: Vector2 = s.vel.orthogonal().normalized()
			push += across * signf(across.dot(d) + 0.01) * (40.0 - dist) * 0.14
	_avoid_hands(ship, push)
	# The walls push back.
	var inner: Rect2 = world.arena.grow(-34.0)
	var wall := Vector2.ZERO
	wall.x = minf(ship.pos.x - inner.position.x, 0.0) + maxf(ship.pos.x - inner.end.x, 0.0)
	wall.y = minf(ship.pos.y - inner.position.y, 0.0) + maxf(ship.pos.y - inner.end.y, 0.0)
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


func _avoid_hands(ship: Ship, _push: Vector2) -> void:
	pass


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
	if shell != null and ship.pos.distance_to(shell.pos) < 120.0 and ship.cooldown <= 0.0:
		wants = true
	elif nearest != null and closest > 30.0 and closest < 90.0 and _boredom > 4.0 and ship.cooldown <= 0.0:
		wants = true
	if wants:
		smask = true
		_boredom = 0.0
		_charge_clock = world.rng.randf_range(0.3, 0.75)
