class_name Shots
extends RefCounted
## What's fired back: slow, round and easy to read.

class Shot:
	var pos: Vector2
	var vel: Vector2
	var tex: Texture2D
	var life: float
	var curve := 0.0
	var accel := 0.0

var world: World
var list: Array[Shot] = []


func _init(the_world: World) -> void:
	world = the_world


func fire(pos: Vector2, vel: Vector2, sprite: String, curve := 0.0, accel := 0.0) -> void:
	if world.finishing():
		return
	var s := Shot.new()
	s.pos = pos
	s.vel = vel
	s.tex = Sprites.get_tex(sprite)
	s.life = Balance.SHOT_LIFE
	s.curve = curve
	s.accel = accel
	list.append(s)


## Fired in a ring, of `count`, `turned` round from the start.
func ring(pos: Vector2, count: int, speed: float, sprite: String, turned := 0.0, curve := 0.0) -> void:
	for i in count:
		fire(pos, Vector2.from_angle(turned + TAU * i / count) * speed, sprite, curve)


func step(dt: float) -> void:
	var ship := world.ship
	var arena: Rect2 = world.arena
	var i := 0
	while i < list.size():
		var s := list[i]
		s.life -= dt
		if s.curve != 0.0:
			s.vel = s.vel.rotated(s.curve * dt)
		if s.accel != 0.0:
			s.vel += s.vel.normalized() * s.accel * dt
		s.pos += s.vel * dt
		var gone := s.life <= 0.0 or not arena.grow(2.0).has_point(s.pos)
		if not gone:
			var reach := Balance.SHOT_RADIUS + Balance.SHIP_RADIUS
			if s.pos.distance_squared_to(ship.pos) < reach * reach:
				if ship.is_smasking():
					world.fx.spark_at(s.pos, Color("fbf236"))
					gone = true
				elif ship.hurt(s.pos):
					gone = true
		if gone:
			list[i] = list[list.size() - 1]
			list.pop_back()
		else:
			i += 1


## Every shot in `radius` of `pos` gone.
func clear_round(pos: Vector2, radius: float) -> void:
	var i := 0
	while i < list.size():
		if list[i].pos.distance_squared_to(pos) < radius * radius:
			world.fx.spark_at(list[i].pos, Color("fbf236"))
			list[i] = list[list.size() - 1]
			list.pop_back()
		else:
			i += 1


## All of them, turned to coins.
func all_to_coins() -> void:
	for s in list:
		world.pickups.drop_coin(s.pos)
	list.clear()


func draw(canvas: CanvasItem) -> void:
	for s in list:
		canvas.draw_texture(s.tex, (s.pos - s.tex.get_size() * 0.5).round())
