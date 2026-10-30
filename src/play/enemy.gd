class_name Enemy
extends RefCounted
## Everything that flies at you. They all move the way the original's did: a
## desired angle turned to quickly, a thrust along wherever they point, and drag.

var world: World
var kind := ""
var pos := Vector2.ZERO
var vel := Vector2.ZERO
var angle := 0.0
var desired_angle := 0.0
var thrust := 0.0
var hp := 1.0
var max_hp := 1.0
var radius := 4.0
var score := 100
var coins := 1
var drag := Balance.DRAG
var turn := Balance.TURN
var sprite := ""
var alive := true
## Whether the missiles go for it (the original's TargetableComponent).
var targetable := true
## Whether it counts towards the hour's zero.
var counted := true
## Whether it's kept inside the walls, and bounced off them rather than stopped.
var walled := true
var bouncy := false
## Whether touching it hurts.
var harmful := true
## Whether other things shove it, and it them.
var pushy := true
## Big things are drawn on top, little things in front of them.
var flash := 0.0
var age := 0.0
var clock := 0.0
var clock2 := 0.0
var last_smask := -1
var bursts_left := 0
## Hermit: the shell's still on.
var shelled := false
## Spawn: its young, still out there.
var young := 0
var parent: Enemy


func setup(the_world: World, the_kind: String) -> Enemy:
	world = the_world
	kind = the_kind
	var def: Dictionary = Enemies.KINDS[kind]
	sprite = def.sprite
	max_hp = float(def.hp) * world.run.toughness()
	hp = max_hp
	radius = def.radius
	score = def.score
	coins = def.coin
	thrust = def.thrust
	age = world.rng.randf() * 3.0
	match kind:
		"froglet":
			clock = world.rng.randf_range(0.2, 0.9)
		"starball":
			bouncy = true
			drag = 0.0
			vel = Vector2.from_angle(world.rng.randf() * TAU) * world.rng.randf_range(60.0, 90.0)
			clock = world.rng.randf_range(1.0, 3.0)
		"spawn":
			pushy = false
			clock = 1.0
		"squid":
			clock = world.rng.randf_range(1.5, 3.0)
		"hermit":
			shelled = true
			targetable = false
			radius = 6.0
	return self


func step(dt: float) -> void:
	age += dt
	flash = maxf(flash - dt * 7.0, 0.0)
	think(dt)
	angle = lerp_angle(angle, desired_angle, clampf(dt * turn, 0.0, 1.0))
	vel += Vector2.from_angle(angle) * thrust * dt
	vel *= exp(-drag * dt)
	pos += vel * dt
	if walled:
		_walls()


func _walls() -> void:
	var inside: Rect2 = world.arena.grow(-radius)
	if pos.x < inside.position.x or pos.x > inside.end.x:
		pos.x = clampf(pos.x, inside.position.x, inside.end.x)
		vel.x = -vel.x if bouncy else 0.0
	if pos.y < inside.position.y or pos.y > inside.end.y:
		pos.y = clampf(pos.y, inside.position.y, inside.end.y)
		vel.y = -vel.y if bouncy else 0.0


func to_ship() -> Vector2:
	return world.ship.pos - pos


func think(dt: float) -> void:
	match kind:
		"froglet":
			_froglet(dt)
		"crab":
			desired_angle = to_ship().angle()
		"starball":
			_starball(dt)
		"tadpole":
			desired_angle = to_ship().angle() + sin(age * 9.0) * 0.7
		"spawn":
			_spawn(dt)
		"squid":
			_squid(dt)
		"urchin":
			desired_angle = to_ship().angle()
		"hermit":
			desired_angle = to_ship().angle()


func _froglet(dt: float) -> void:
	clock -= dt
	desired_angle = to_ship().angle()
	if clock <= 0.0:
		clock = world.rng.randf_range(0.7, 1.1)
		vel += Vector2.from_angle(desired_angle) * world.rng.randf_range(100.0, 130.0)
		if world.rng.randf() < 0.3:
			world.sfx("hop", -16.0, world.rng.randf_range(0.9, 1.2))


func _starball(dt: float) -> void:
	clock -= dt
	desired_angle = age * 3.0
	if clock <= 0.0:
		clock = world.rng.randf_range(2.6, 3.8)
		world.shots.fire(pos, to_ship().normalized() * 72.0, "shot_star")
		world.sfx("shot", -12.0, 1.1)


func _spawn(dt: float) -> void:
	clock -= dt
	if clock <= 0.0 and young < 5:
		clock = 2.4
		var e := world.add_kind("tadpole", pos + Vector2.from_angle(world.rng.randf() * TAU) * 10.0)
		e.parent = self
		young += 1
		world.sfx("spawn", -10.0, world.rng.randf_range(0.9, 1.2))
		world.fx.burst(pos, Color("99e550"), 4, 50.0, world.rng)


func _squid(dt: float) -> void:
	var to := to_ship()
	var dist := to.length()
	if dist > 130.0:
		desired_angle = to.angle()
	elif dist < 90.0:
		desired_angle = (-to).angle()
	else:
		desired_angle = to.angle() + PI * 0.5
	if bursts_left > 0:
		clock2 -= dt
		if clock2 <= 0.0:
			clock2 = 0.18
			bursts_left -= 1
			world.shots.fire(pos, to.normalized() * 95.0, "shot_round")
			world.sfx("shot", -12.0)
	else:
		clock -= dt
		if clock <= 0.0:
			clock = world.rng.randf_range(2.8, 3.6)
			bursts_left = 3
			clock2 = 0.4
			flash = 1.0


## What it's looking at itself as: the original's sprites face up.
func draw_rotation() -> float:
	var r := angle + PI * 0.5
	match kind:
		"spawn":
			return 0.0
		"starball":
			return age * 3.0
		"urchin":
			return floorf(age * 3.0) * PI * 0.25
	return snappedf(r, TAU / 16.0)


func tex() -> Texture2D:
	var frame := 1 + int(age * 5.0) % 2
	var name := sprite
	if kind == "hermit" and not shelled:
		name = "yellowcrab"
	if kind == "froglet":
		frame = 1 if clock > 0.55 else 2
	return Sprites.get_tex("%s%d" % [name, frame])


func draw_shadow(canvas: CanvasItem) -> void:
	Sprites.draw(canvas, tex(), pos + Vector2(1, 3), draw_rotation(), Color(0, 0, 0, 0.35))


func draw(canvas: CanvasItem) -> void:
	Sprites.draw(canvas, tex(), pos, draw_rotation())


func draw_flash(canvas: CanvasItem) -> void:
	if flash > 0.0:
		Sprites.draw(canvas, tex(), pos, draw_rotation(), Color(1, 1, 1, minf(flash, 1.0)))


## Hit by `how`: "missile", "smask" or "shock". Returns true if it's killed it.
func damage(amount: float, how: String) -> bool:
	if not alive:
		return false
	if shelled:
		if how == "missile":
			flash = 0.5
			world.sfx("clank", -14.0, world.rng.randf_range(0.9, 1.2))
			return false
		_crack()
		return false
	# A boss's part that isn't up yet: it takes nothing, and sounds like it.
	if not targetable:
		flash = 0.5
		world.sfx("clank", -8.0)
		return false
	hp -= amount
	flash = 1.0
	if hp <= 0.0:
		world.kill(self, how)
		return true
	return false


func _crack() -> void:
	shelled = false
	targetable = true
	radius = 4.0
	thrust = 150.0
	flash = 1.0
	world.sfx("crack")
	world.fx.shards(Sprites.get_tex("hermit1"), pos, vel, world.rng)
	world.fx.ring(pos, 18.0, 0.2, Color("cbdbfc"))
	world.fx.shake(3.0)
	vel += (pos - world.ship.pos).normalized() * 180.0


## Last words, when it's gone.
func on_death() -> void:
	match kind:
		"urchin":
			for i in 8:
				world.shots.fire(pos, Vector2.from_angle(TAU * i / 8.0) * 80.0, "shot_small")
		"tadpole":
			if parent and parent.alive:
				parent.young -= 1


func is_boss_part() -> bool:
	return false


## What's under all the things, for what's got anything to draw there.
func draw_under(_canvas: CanvasItem) -> void:
	pass
