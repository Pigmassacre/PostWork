class_name Pickups
extends RefCounted
## Coins from what's been killed, and now and then a coffee.

class Pickup:
	var pos: Vector2
	var vel: Vector2
	var coffee := false
	var life := 0.0
	var age := 0.0

var world: World
var list: Array[Pickup] = []
var vacuum := false
var _coin_clock := 0.0


func _init(the_world: World) -> void:
	world = the_world


func drop_coin(pos: Vector2) -> void:
	if list.size() > 160:
		return
	var p := Pickup.new()
	p.pos = pos
	p.vel = Vector2.from_angle(world.rng.randf() * TAU) * world.rng.randf_range(30.0, 110.0)
	p.life = Balance.COIN_LIFE
	list.append(p)


func drop_coffee(pos: Vector2) -> void:
	var p := Pickup.new()
	p.pos = pos
	p.coffee = true
	p.life = Balance.COIN_LIFE * 2.0
	list.append(p)


func step(dt: float) -> void:
	var ship := world.ship
	var reach := Balance.COIN_REACH * (2.0 if world.run.has("magnet") else 1.0)
	_coin_clock = maxf(_coin_clock - dt, 0.0)
	var i := 0
	while i < list.size():
		var p := list[i]
		p.age += dt
		p.life -= dt
		var to := ship.pos - p.pos
		var dist := to.length()
		var alive := ship.state != Ship.State.DEAD
		if alive and (vacuum or dist < reach) and p.age > 0.2:
			p.vel += to.normalized() * Balance.COIN_PULL * dt * (3.0 if vacuum else 1.0)
			p.vel *= exp(-3.0 * dt)
		else:
			p.vel *= exp(-4.0 * dt)
		p.pos += p.vel * dt
		p.pos = p.pos.clamp(world.arena.position + Vector2(3, 3), world.arena.end - Vector2(3, 3))
		if alive and dist < 9.0 and p.age > 0.1:
			_collect(p)
			p.life = 0.0
		if p.life <= 0.0:
			list[i] = list[list.size() - 1]
			list.pop_back()
		else:
			i += 1


func _collect(p: Pickup) -> void:
	var run := world.run
	if p.coffee:
		run.hull = mini(run.hull + 1, run.max_hull)
		world.sfx("coffee")
		world.say_word("COFFEE", Color("eec39a"))
		world.fx.ring(p.pos, 20.0, 0.25, Color("eec39a"))
		return
	run.score += Balance.COIN_VALUE * run.multiplier()
	if _coin_clock <= 0.0:
		_coin_clock = 0.05
		world.sfx("coin", -12.0, world.rng.randf_range(0.95, 1.2))
	world.fx.spark_at(p.pos, Color("fbf236"))


func draw(canvas: CanvasItem) -> void:
	for p in list:
		# They blink out before they're gone.
		if p.life < 1.5 and int(p.life * 10.0) % 2 == 0:
			continue
		var tex: Texture2D
		if p.coffee:
			tex = Sprites.get_tex("coffee")
			canvas.draw_texture(tex, (p.pos + Vector2(1, 2) - tex.get_size() * 0.5).round(), Color(0, 0, 0, 0.35))
		else:
			tex = Sprites.get_tex("coin%d" % [1, 2, 3, 4, 3, 2][int(p.age * 12.0) % 6])
		canvas.draw_texture(tex, (p.pos - tex.get_size() * 0.5).round())
