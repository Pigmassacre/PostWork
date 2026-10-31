class_name Fx
extends RefCounted
## Everything that's only there to look good: rings, sparks, shards, smoke, the
## shake, the flash, the hit stop, words in the air.

class Particle:
	var pos: Vector2
	var vel: Vector2
	var life: float
	var total: float
	var color: Color
	var size: float
	var drag: float

class Ring:
	var pos: Vector2
	var radius: float
	var time: float
	var total: float
	var color: Color

class Shard:
	var pos: Vector2
	var vel: Vector2
	var tex: Texture2D
	var region: Rect2
	var rot: float
	var spin: float
	var life: float

class Word:
	var pos: Vector2
	var text: String
	var color: Color
	var life: float
	var total: float

class Ripple:
	var pos: Vector2
	var age: float
	var strength: float

const MAX_PARTICLES := 700
const RIPPLE_LIFE := 0.55

var world: World
var particles: Array[Particle] = []
var smoke: Array[Particle] = []
var rings: Array[Ring] = []
var shards_list: Array[Shard] = []
var words: Array[Word] = []
var ripples: Array[Ripple] = []
var trauma := 0.0
var freeze := 0.0
var flash_color := Color.BLACK
var flash_amount := 0.0
var aberration := 0.0
## How hard a wall's just been hit, for its glow.
var wall_hit := 0.0
var offset := Vector2.ZERO
var _time := 0.0


func _init(the_world: World) -> void:
	world = the_world


func shake(amount: float) -> void:
	trauma = minf(trauma + amount * float(Game.settings.shake), 14.0)


func hitstop(seconds: float) -> void:
	freeze = maxf(freeze, seconds)


func flash(color: Color, amount: float) -> void:
	if not Game.settings.flashes:
		amount *= 0.25
	flash_color = color
	flash_amount = maxf(flash_amount, amount)
	aberration = maxf(aberration, amount)


func ripple(pos: Vector2, strength: float) -> void:
	var r := Ripple.new()
	r.pos = pos
	r.strength = strength
	ripples.append(r)
	if ripples.size() > 4:
		ripples.pop_front()


func ring(pos: Vector2, radius: float, time: float, color: Color) -> void:
	var r := Ring.new()
	r.pos = pos
	r.radius = radius
	r.time = 0.0
	r.total = time
	r.color = color
	rings.append(r)


func _particle(list: Array[Particle], pos: Vector2, vel: Vector2, life: float, color: Color, size: float, drag: float) -> void:
	if list.size() >= MAX_PARTICLES:
		list[randi() % list.size()] = list[list.size() - 1]
		list.pop_back()
	var p := Particle.new()
	p.pos = pos
	p.vel = vel
	p.life = life
	p.total = life
	p.color = color
	p.size = size
	p.drag = drag
	list.append(p)


func burst(pos: Vector2, color: Color, count: int, speed: float, rng: RandomNumberGenerator) -> void:
	for i in count:
		_particle(particles, pos, Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(0.2, 1.0) * speed,
			rng.randf_range(0.2, 0.55), color, 1.0 + float(rng.randf() < 0.3), 3.0)


func sparks(pos: Vector2, normal: Vector2, count: int, rng: RandomNumberGenerator) -> void:
	for i in count:
		_particle(particles, pos, normal.rotated(rng.randf_range(-1.1, 1.1)) * rng.randf_range(40.0, 150.0),
			rng.randf_range(0.12, 0.3), Color("fbf236"), 1.0, 3.0)


func spark_at(pos: Vector2, color: Color) -> void:
	_particle(particles, pos, Vector2.ZERO, 0.12, color, 2.0, 0.0)


func hit_spark(pos: Vector2, vel: Vector2, rng: RandomNumberGenerator) -> void:
	_particle(particles, pos, Vector2.ZERO, 0.07, Color.WHITE, 3.0, 0.0)
	for i in 2:
		_particle(particles, pos, vel.normalized().rotated(rng.randf_range(-0.9, 0.9)) * -rng.randf_range(40.0, 120.0),
			rng.randf_range(0.1, 0.22), Color("5fcde4"), 1.0, 2.0)


func puff(pos: Vector2, vel: Vector2, rng: RandomNumberGenerator) -> void:
	_particle(smoke, pos + Vector2(rng.randf_range(-1.5, 1.5), rng.randf_range(-1.5, 1.5)), vel, rng.randf_range(0.15, 0.4),
		[Color("df7126"), Color("fbf236"), Color("696a6a")][rng.randi() % 3], 1.0 + float(rng.randf() < 0.3), 2.0)


func streak(pos: Vector2, vel: Vector2, rng: RandomNumberGenerator) -> void:
	_particle(particles, pos + vel.orthogonal().normalized() * rng.randf_range(-5.0, 5.0), vel * rng.randf_range(0.0, 0.1), rng.randf_range(0.15, 0.35),
		Color("fbf236") if rng.randf() < 0.6 else Color.WHITE, 2.0, 1.0)


## A sprite in pieces, flying off.
func shards(tex: Texture2D, pos: Vector2, vel: Vector2, rng: RandomNumberGenerator, pieces := 2) -> void:
	var size := tex.get_size()
	var cell := size / float(pieces)
	for y in pieces:
		for x in pieces:
			var s := Shard.new()
			s.tex = tex
			s.region = Rect2(Vector2(x, y) * cell, cell)
			s.pos = pos + (Vector2(x, y) * cell + cell * 0.5 - size * 0.5)
			var away := (s.pos - pos).normalized().rotated(rng.randf_range(-0.5, 0.5))
			s.vel = vel * 0.4 + away * rng.randf_range(50.0, 170.0)
			s.rot = 0.0
			s.spin = rng.randf_range(-12.0, 12.0)
			s.life = rng.randf_range(0.35, 0.7)
			shards_list.append(s)


## Words in the air: a score, or what's just happened.
func word(pos: Vector2, text: String, color: Color, life := 0.7) -> void:
	var w := Word.new()
	w.pos = pos
	w.text = text
	w.color = color
	w.life = life
	w.total = life
	words.append(w)
	if words.size() > 24:
		words.pop_front()


## Runs in real time, under the hit stops and the slow motion.
func step(dt: float) -> void:
	_time += dt
	trauma = maxf(trauma - (trauma * 4.0 + 2.0) * dt, 0.0)
	flash_amount = maxf(flash_amount - dt * 2.5, 0.0)
	aberration = maxf(aberration - dt * 3.0, 0.0)
	wall_hit = maxf(wall_hit - dt * 3.0, 0.0)
	var shake_now := trauma * trauma * 0.1 + trauma * 0.25
	offset = Vector2(sin(_time * 71.0) + sin(_time * 37.0), cos(_time * 67.0) + sin(_time * 43.0)) * 0.5 * shake_now
	_step_particles(particles, dt)
	_step_particles(smoke, dt)
	var i := 0
	while i < rings.size():
		rings[i].time += dt
		if rings[i].time >= rings[i].total:
			rings.remove_at(i)
		else:
			i += 1
	i = 0
	while i < shards_list.size():
		var s := shards_list[i]
		s.life -= dt
		s.pos += s.vel * dt
		s.vel *= exp(-2.5 * dt)
		s.rot += s.spin * dt
		if s.life <= 0.0:
			shards_list.remove_at(i)
		else:
			i += 1
	i = 0
	while i < words.size():
		var w := words[i]
		w.life -= dt
		w.pos.y -= dt * 22.0
		if w.life <= 0.0:
			words.remove_at(i)
		else:
			i += 1
	i = 0
	while i < ripples.size():
		ripples[i].age += dt
		if ripples[i].age >= RIPPLE_LIFE:
			ripples.remove_at(i)
		else:
			i += 1


func _step_particles(list: Array[Particle], dt: float) -> void:
	var i := 0
	while i < list.size():
		var p := list[i]
		p.life -= dt
		if p.life <= 0.0:
			list[i] = list[list.size() - 1]
			list.pop_back()
			continue
		p.pos += p.vel * dt
		if p.drag > 0.0:
			p.vel *= exp(-p.drag * dt)
		i += 1


func draw_smoke(canvas: CanvasItem) -> void:
	for p in smoke:
		var c := p.color
		c.a = clampf(p.life / p.total * 1.5, 0.0, 1.0)
		canvas.draw_rect(Rect2(p.pos.round(), Vector2(p.size, p.size)), c)
	for s in shards_list:
		canvas.draw_set_transform(s.pos.round(), s.rot, Vector2.ONE)
		canvas.draw_texture_rect_region(s.tex, Rect2(-s.region.size * 0.5, s.region.size), s.region)
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)


## What's drawn additively, so it shines.
func draw_add(canvas: CanvasItem) -> void:
	for p in particles:
		var c := p.color
		c.a = clampf(p.life / p.total * 1.5, 0.0, 1.0)
		canvas.draw_rect(Rect2(p.pos.round() - Vector2(p.size, p.size) * 0.5, Vector2(p.size, p.size)), c)
	for r in rings:
		var t := r.time / r.total
		var eased := 1.0 - (1.0 - t) * (1.0 - t)
		var c := r.color
		c.a = 1.0 - t
		canvas.draw_arc(r.pos.round(), maxf(r.radius * eased, 1.0), 0.0, TAU, 32 + int(r.radius * 0.5), c, 1.0 + (1.0 - t) * 2.0)
