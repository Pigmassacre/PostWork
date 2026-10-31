class_name World
extends Node2D
## The floor and everything on it, and the hour being played. It steps itself in
## small steps of its own time, and draws everything in a few layers.

signal hour_cleared
signal ship_dead
signal evening_over
signal hint_wanted(id: String)
signal banner_wanted(big: String, small: String, color: Color)
signal word_said(text: String, color: Color)

enum Phase { INTRO, FIGHT, CLEARED, WAITING, OVER }

const MAX_STEP := 1.0 / 60.0
const GRID_CELL := 24.0
const HUE_SPEED := 0.03

var run: Run
var ship: Ship
var missiles: Missiles
var shots: Shots
var pickups: Pickups
var fx: Fx
var rng: RandomNumberGenerator
var enemies: Array[Enemy] = []
## What the missiles can go for, this step.
var targets: Array[Enemy] = []
## The title's demo: plays itself, silently, for ever.
var demo := false
var arena := Rect2(-150, -88, 300, 176)
var arena_full := Vector2(300, 176)
var phase := Phase.INTRO
var phase_clock := 0.0
## The hour's count: what's left of it, and the most it's been.
var remaining := 0
var total := 1
var floor_pop := 0.0
## Counts down from 1 from the moment the hour's hit zero, for the UI.
var zero_time := 0.0
var boss: Enemy
var bumpers: Array[Dictionary] = []
var hour_day := 0.0
var hue := 0.0
## The screen this is shown on (src/ui/game_view.gd).
var view: GameView
## How far the camera's off the floor's middle, in pixels, for the title's slab.
var camera_shift := Vector2.ZERO

var _waves: Array = []
var _wave_clock := 0.0
var _warnings: Array[Dictionary] = []
var _grid := {}
var _camera: Camera2D
var _floor_layer: Layer
var _main_layer: Layer
var _add_layer: Layer
var _slowmo := 1.0
var _clear_clock := 0.0
var _shrink := false
var _post_material: ShaderMaterial
var _floor_tile: Texture2D
var _shown_remaining := 0
var _time_outside := 0.0


func setup(the_run: Run, is_demo := false) -> void:
	run = the_run
	demo = is_demo
	rng = run.rng
	ship = Ship.new(self, run)
	missiles = Missiles.new(self)
	shots = Shots.new(self)
	pickups = Pickups.new(self)
	fx = Fx.new(self)
	if demo or Game.autoplay:
		ship.auto = Autopilot.new(self)


func _ready() -> void:
	_floor_tile = Sprites.get_tex("bg")
	_camera = Camera2D.new()
	add_child(_camera)
	_camera.make_current()
	_floor_layer = _layer(_paint_floor)
	_floor_layer.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_main_layer = _layer(_paint_main)
	_add_layer = _layer(_paint_add)
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_add_layer.material = add
	start_hour()


func _layer(painter: Callable) -> Layer:
	var l := Layer.new()
	l.painter = painter
	add_child(l)
	return l


func set_post_material(material: ShaderMaterial) -> void:
	_post_material = material


# --- the hours ------------------------------------------------------------------


func start_hour() -> void:
	var hour := run.hour()
	if Game.autoplay and not demo:
		print("%s %s: run time %.1f, score %d, hull %d, kills %d, perks %s" % [Hours.clock_text(int(hour.clock)), hour.name, run.time, run.score, run.hull, run.kills, run.perks])
	run.hits_this_hour = 0
	run.hour_time = 0.0
	run.minutes = 0
	arena_full = hour.arena
	_waves = (hour.waves as Array).duplicate(true)
	var crowd := run.crowding()
	remaining = 0
	for wave: Dictionary in _waves:
		for kind: String in wave.spawn:
			wave.spawn[kind] = maxi(1, roundi(int(wave.spawn[kind]) * crowd))
			remaining += int(wave.spawn[kind])
	total = maxi(remaining, 1)
	_wave_clock = 0.0
	boss = null
	_shrink = hour.get("feature", "") == "shrink"
	_make_bumpers(hour.get("feature", ""))
	phase = Phase.INTRO
	phase_clock = 2.0 if not demo else 0.6
	pickups.vacuum = false
	_shown_remaining = remaining
	if not demo:
		var title: String = Hours.clock_text(int(hour.clock))
		banner_wanted.emit(title, hour.name, Color("fbf236") if hour.has("boss") else Color("cbdbfc"))
		sfx("warning" if hour.has("boss") else "hour")
		Audio.play_music(hour.music, 1.5)


func _make_bumpers(feature: String) -> void:
	bumpers.clear()
	if feature != "bumpers":
		return
	var half := arena_full * 0.5
	for spot: Vector2 in [Vector2(-0.5, -0.45), Vector2(0.5, -0.45), Vector2(-0.5, 0.45), Vector2(0.5, 0.45), Vector2(0.0, 0.0)]:
		bumpers.append({"pos": Vector2(spot.x * half.x, spot.y * half.y), "lit": 0.0})


func _start_fight() -> void:
	phase = Phase.FIGHT
	var hour := run.hour()
	if hour.has("boss"):
		var script: Script = load("res://src/play/bosses/%s.gd" % hour.boss)
		boss = script.new()
		boss.world = self
		boss.call("enter")
		if remaining <= 0:
			remaining = 1
		total = maxi(remaining, 1)
		_shown_remaining = remaining


func _step_waves(dt: float) -> void:
	if phase != Phase.FIGHT or _waves.is_empty():
		return
	_wave_clock -= dt
	var living := 0
	for e in enemies:
		if e.counted:
			living += 1
	if _wave_clock <= 0.0 or (living <= 2 and _warnings.is_empty()):
		_next_wave()


func _next_wave() -> void:
	var wave: Dictionary = _waves.pop_front()
	_wave_clock = wave.get("gap", 10.0)
	if wave.has("hint") and not demo:
		hint_wanted.emit(wave.hint)
	for kind: String in wave.spawn:
		var groups := _spawn_group(kind, int(wave.spawn[kind]))
		for at: Vector2 in groups:
			_warnings.append({"kind": kind, "pos": at, "time": Balance.SPAWN_WARNING + rng.randf() * 0.35})
	sfx("spawn", -8.0)


func _spawn_group(kind: String, count: int) -> Array:
	var points := []
	# Tadpoles come as a shoal, the rest from all over.
	if kind == "tadpole":
		var centre := _spawn_point()
		for i in count:
			points.append(_inside(centre + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(0.0, 34.0)))
	else:
		for i in count:
			points.append(_spawn_point())
	return points


func _inside(p: Vector2) -> Vector2:
	var keep := arena.grow(-Balance.SPAWN_MARGIN)
	return p.clamp(keep.position, keep.end)


func _spawn_point() -> Vector2:
	var keep := arena.grow(-Balance.SPAWN_MARGIN)
	var p := Vector2.ZERO
	for i in 16:
		p = Vector2(rng.randf_range(keep.position.x, keep.end.x), rng.randf_range(keep.position.y, keep.end.y))
		if p.distance_to(ship.pos) > Balance.SPAWN_AWAY_FROM_SHIP:
			return p
	return p


func _step_warnings(dt: float) -> void:
	var i := 0
	while i < _warnings.size():
		_warnings[i].time -= dt
		if _warnings[i].time <= 0.0:
			var w: Dictionary = _warnings[i]
			_warnings.remove_at(i)
			var e := Enemy.new().setup(self, w.kind)
			e.pos = w.pos
			enemies.append(e)
			fx.burst(e.pos, Color("cbdbfc"), 5, 60.0, rng)
		else:
			i += 1


## A new thing on the floor, on top of the hour's count.
func add_kind(kind: String, pos: Vector2) -> Enemy:
	var e := Enemy.new().setup(self, kind)
	e.pos = pos
	add_enemy(e)
	return e


func add_enemy(e: Enemy) -> void:
	e.world = self
	enemies.append(e)
	if e.counted:
		remaining += 1
		total = maxi(total, remaining)


# --- killing things ------------------------------------------------------------


func kill(e: Enemy, how: String) -> void:
	if not e.alive:
		return
	e.alive = false
	e.on_death()
	var earned := run.add_kill(e.score)
	var big := e.radius >= 6.0 or e.is_boss_part()
	if e.tex() != null:
		fx.shards(e.tex(), e.pos, e.vel, rng)
	fx.burst(e.pos, Color("fbf236"), 8 if not big else 22, 150.0 if not big else 240.0, rng)
	fx.ring(e.pos, 16.0 if not big else 40.0, 0.22, Color("df7126"))
	fx.shake(0.7 if not big else 4.0)
	if big:
		fx.ripple(e.pos, 0.5)
		fx.hitstop(0.05)
		sfx("boom_big", -3.0, rng.randf_range(0.9, 1.1))
	else:
		sfx("boom", -7.0, rng.randf_range(0.85, 1.2))
	if run.multiplier() > 1 or big:
		fx.word(e.pos + Vector2(0, -6), str(earned), Color("fbf236") if big else Color("cbdbfc"))
	for i in e.coins:
		pickups.drop_coin(e.pos)
	var chance := Balance.COFFEE_LOW_CHANCE if run.hull <= Balance.COFFEE_LOW_HULL else Balance.COFFEE_CHANCE
	if run.hull < run.max_hull and rng.randf() < chance:
		pickups.drop_coffee(e.pos)
	if how == "smask":
		fx.hitstop(0.06)
		ship.on_smask_kill()
		sfx("smask_hit", -2.0)
		rumble(0.5)
	if e.counted:
		remaining -= 1
		floor_pop = 1.0
		_update_clock()
		if remaining <= 0 and _waves.is_empty() and _warnings.is_empty() and phase == Phase.FIGHT:
			_on_zero(e.pos)


func _update_clock() -> void:
	if total > 0:
		run.minutes = clampi(roundi(59.0 * (1.0 - float(remaining) / float(total))), 0, 59)


func _on_zero(at: Vector2) -> void:
	if demo:
		run.hour_index = (run.hour_index + 1) % (Hours.EVENING.size() - 1)
		_clear_clock = 1.2
		phase = Phase.CLEARED
		return
	phase = Phase.CLEARED
	_clear_clock = 1.6
	_slowmo = 0.2
	var hour := run.hour()
	var bonus := Balance.CLEAR_BONUS * run.multiplier()
	var lines := "+%d" % bonus
	if run.hits_this_hour == 0:
		bonus += Balance.NO_HIT_BONUS
		lines += "  NO HIT +%d" % Balance.NO_HIT_BONUS
	if run.hour_time < Balance.QUICK_BONUS_TIME and not hour.has("boss"):
		bonus += Balance.QUICK_BONUS
		lines += "  SPEED +%d" % Balance.QUICK_BONUS
	run.score += bonus
	run.minutes = 59
	shots.all_to_coins()
	missiles.clear()
	pickups.vacuum = true
	fx.flash(Color("fbf236"), 0.5)
	fx.shake(9.0)
	fx.ripple(at, 1.0)
	fx.ring(at, 240.0, 0.8, Color("fbf236"))
	zero_time = 1.0
	sfx("boom_big", 0.0, 0.8)
	sfx("zero", 0.0)
	rumble(1.0)
	banner_wanted.emit("ZERO", lines, Color("fbf236"))


## How many things `pos` has hit with a shock wave, and it shoved them.
func shock(pos: Vector2, radius: float, damage: float) -> void:
	fx.ring(pos, radius, 0.28, Color("fbf236"))
	fx.ring(pos, radius * 0.6, 0.2, Color("df7126"))
	fx.ripple(pos, 0.9)
	fx.burst(pos, Color("fbf236"), 20, radius * 3.0, rng)
	shots.clear_round(pos, radius)
	for e: Enemy in enemies.duplicate():
		var reach := radius + e.radius
		if e.alive and e.pos.distance_squared_to(pos) < reach * reach:
			if e.pushy:
				e.vel += (e.pos - pos).normalized() * 260.0
			e.damage(damage, "shock")


## Just the shove, as when the ship's hit.
func shove_from(pos: Vector2, radius: float, strength: float) -> void:
	for e in enemies:
		if e.pushy and e.pos.distance_squared_to(pos) < radius * radius:
			e.vel += (e.pos - pos).normalized() * strength


## Hurts what's around `pos` but not `spared`.
func splash(pos: Vector2, radius: float, damage: float, spared: Enemy) -> void:
	fx.ring(pos, radius, 0.14, Color("df7126"))
	for e: Enemy in enemies.duplicate():
		if e == spared or not e.alive or not e.targetable:
			continue
		var reach := radius + e.radius
		if e.pos.distance_squared_to(pos) < reach * reach:
			e.damage(damage, "missile")


func random_target() -> Enemy:
	return null if targets.is_empty() else targets[rng.randi() % targets.size()]


func on_ship_dead() -> void:
	phase = Phase.OVER
	_slowmo = 0.3
	fx.flash(Color.WHITE, 1.0)
	fx.shake(14.0)
	fx.hitstop(0.25)
	fx.ripple(ship.pos, 1.0)
	fx.shards(Sprites.get_tex("ship1"), ship.pos, ship.vel, rng, 4)
	fx.burst(ship.pos, Color("fbf236"), 40, 280.0, rng)
	fx.ring(ship.pos, 120.0, 0.6, Color("d95763"))
	sfx("death")
	Audio.set_engine(0.0, 1.0)
	ship_dead.emit()


func finishing() -> bool:
	return phase == Phase.CLEARED or phase == Phase.WAITING


## The player's chosen and the next hour's to begin.
func next_hour() -> void:
	if run.hour_index + 1 >= Hours.EVENING.size() and run.mode == Run.EVENING:
		evening_over.emit()
		phase = Phase.OVER
		return
	run.hour_index += 1
	# A coffee break, on the house.
	run.hull = mini(run.hull + 1, run.max_hull)
	start_hour()


func say_word(text: String, color: Color) -> void:
	fx.word(ship.pos + Vector2(0, -14), text, color, 1.2)
	word_said.emit(text, color)


func sfx(sound: String, volume_db := 0.0, pitch := 1.0) -> void:
	if not demo:
		Audio.play(sound, volume_db, pitch)


func rumble(amount: float) -> void:
	if not demo:
		Inputs.rumble(amount)


func is_invincible() -> bool:
	return demo or Game.invincible


func controls_live() -> bool:
	return not demo and (phase == Phase.INTRO or phase == Phase.FIGHT or phase == Phase.CLEARED)


func to_screen(pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform() * pos


func pointer() -> Vector2:
	return view.pointer()


# --- the loop ----------------------------------------------------------------------


func _process(delta: float) -> void:
	fx.step(delta)
	_time_outside += delta
	hue += delta * HUE_SPEED * (1.0 + 0.25 * float(run.multiplier() - 1))
	if fx.freeze > 0.0:
		fx.freeze -= delta
	else:
		var scale := _time_scale()
		var left := delta * scale
		while left > 0.0:
			var dt := minf(left, MAX_STEP)
			_step(dt)
			left -= dt
	if not demo:
		_update_audio()
		if Game.autoplay and Engine.get_process_frames() % 300 == 0:
			print("fps %d, things %d, missiles %d, shots %d, sparks %d" % [Engine.get_frames_per_second(), enemies.size(), missiles.count, shots.list.size(), fx.particles.size()])
	_camera.position = _camera_target() + fx.offset
	_update_post()
	floor_pop = maxf(floor_pop - delta * 4.0, 0.0)
	zero_time = maxf(zero_time - delta, 0.0)
	_floor_layer.queue_redraw()
	_main_layer.queue_redraw()
	_add_layer.queue_redraw()


func _time_scale() -> float:
	var scale := 1.0
	if ship.state == Ship.State.CHARGING and ship.charge_time > 0.08:
		scale = Balance.CHARGE_SLOWMO
	return scale * _slowmo


func _camera_target() -> Vector2:
	# The floor's kept below the HUD; it leans a touch the way the ship is.
	var lean := ship.pos * 0.035 + ship.vel * 0.006
	return Vector2(0, -8) + lean.round() + camera_shift


func _step(dt: float) -> void:
	if phase == Phase.WAITING:
		return
	run.tick(dt)
	if phase == Phase.INTRO:
		phase_clock -= dt
		if phase_clock <= 0.0:
			_start_fight()
	_step_arena(dt)
	_step_waves(dt)
	_step_warnings(dt)
	ship.step(dt)
	targets.clear()
	for e in enemies:
		if e.alive:
			e.step(dt)
	_rebuild_grid()
	for e in enemies:
		if e.alive and e.targetable:
			targets.append(e)
	_separate(dt)
	missiles.step(dt)
	shots.step(dt)
	pickups.step(dt)
	_contacts()
	_step_bumpers(dt)
	# Dead ones go at the end, so no list changes under anyone's feet.
	var i := 0
	while i < enemies.size():
		if not enemies[i].alive:
			enemies[i] = enemies[enemies.size() - 1]
			enemies.pop_back()
		else:
			i += 1
	_step_phase(dt)


func _step_arena(dt: float) -> void:
	var goal := arena_full
	if _shrink and phase == Phase.FIGHT:
		var shrunk := arena.size - Vector2(Balance.SHRINK_SPEED, Balance.SHRINK_SPEED * 0.55) * dt
		goal = Vector2(maxf(shrunk.x, arena_full.x * Balance.SHRINK_LIMIT), maxf(shrunk.y, arena_full.y * Balance.SHRINK_LIMIT))
		arena.size = goal
	else:
		arena.size = arena.size.lerp(goal, clampf(dt * 3.0, 0.0, 1.0))
	arena.position = -arena.size * 0.5


func _step_phase(dt: float) -> void:
	match phase:
		Phase.FIGHT:
			# A boss's parts can be all that's holding the count up.
			if remaining <= 0 and _waves.is_empty() and _warnings.is_empty():
				_on_zero(ship.pos)
		Phase.CLEARED:
			_clear_clock -= dt / maxf(_slowmo, 0.01)
			_slowmo = minf(_slowmo + dt * 2.0, 1.0)
			if _clear_clock <= 0.0:
				_slowmo = 1.0
				if demo:
					start_hour()
				elif pickups.list.is_empty() or _clear_clock < -2.0:
					phase = Phase.WAITING
					hour_cleared.emit()
		Phase.OVER:
			_slowmo = minf(_slowmo + dt * 0.3, 1.0)


func _rebuild_grid() -> void:
	_grid.clear()
	for e in enemies:
		if not e.alive or not e.targetable:
			continue
		var reach := e.radius + 2.0
		var x0 := floori((e.pos.x - reach) / GRID_CELL)
		var x1 := floori((e.pos.x + reach) / GRID_CELL)
		var y0 := floori((e.pos.y - reach) / GRID_CELL)
		var y1 := floori((e.pos.y + reach) / GRID_CELL)
		for y in range(y0, y1 + 1):
			for x in range(x0, x1 + 1):
				var key := (x + 4096) * 8192 + (y + 4096)
				if _grid.has(key):
					_grid[key].append(e)
				else:
					_grid[key] = [e]


## The first thing a missile hits going from `a` to `b`.
func grid_hit(a: Vector2, b: Vector2) -> Enemy:
	var key := (floori(b.x / GRID_CELL) + 4096) * 8192 + (floori(b.y / GRID_CELL) + 4096)
	var found := _check_cell(key, a, b)
	if found:
		return found
	var key_a := (floori(a.x / GRID_CELL) + 4096) * 8192 + (floori(a.y / GRID_CELL) + 4096)
	return null if key_a == key else _check_cell(key_a, a, b)


func _check_cell(key: int, a: Vector2, b: Vector2) -> Enemy:
	var cell = _grid.get(key)
	if cell == null:
		return null
	var ab := b - a
	var len2 := ab.length_squared()
	for e: Enemy in cell:
		if not e.alive:
			continue
		var t := 0.0 if len2 <= 0.0 else clampf((e.pos - a).dot(ab) / len2, 0.0, 1.0)
		var reach := e.radius + 1.0
		if (a + ab * t).distance_squared_to(e.pos) < reach * reach:
			return e
	return null


func _separate(dt: float) -> void:
	# A soft shove between neighbours, so they don't all stack up on one pixel.
	for cell: Array in _grid.values():
		var n := cell.size()
		if n < 2:
			continue
		for i in mini(n, 8):
			var a: Enemy = cell[i]
			if not a.pushy:
				continue
			for j in range(i + 1, mini(n, 8)):
				var b: Enemy = cell[j]
				if not b.pushy:
					continue
				var d := b.pos - a.pos
				var reach := a.radius + b.radius
				var len2 := d.length_squared()
				if len2 < reach * reach and len2 > 0.01:
					var push := d.normalized() * Balance.SEPARATION * dt
					a.pos -= push
					b.pos += push


func _contacts() -> void:
	if ship.state == Ship.State.DEAD:
		return
	var smasking := ship.is_smasking()
	var ramming: bool = run.has("ram") and ship.speed_fraction() > 0.75
	var reach_bonus := Balance.SMASK_RADIUS if smasking else Balance.SHIP_RADIUS
	for e: Enemy in enemies:
		if not e.alive or not (e.harmful or smasking):
			continue
		var reach := e.radius + reach_bonus
		if e.pos.distance_squared_to(ship.pos) >= reach * reach:
			continue
		if smasking:
			if e.last_smask != ship.smask_id:
				e.last_smask = ship.smask_id
				e.vel += ship.vel * 0.4
				fx.hitstop(0.03)
				fx.shake(2.0)
				fx.burst(e.pos, Color.WHITE, 6, 200.0, rng)
				sfx("clank" if not e.damage(ship.smask_damage(), "smask") else "hit", -8.0)
		elif ramming and e.max_hp <= 14.0 and not e.shelled and e.targetable:
			e.damage(e.hp + 1.0, "smask")
		else:
			ship.hurt(e.pos)
			break
	if smasking:
		shots.clear_round(ship.pos, Balance.SMASK_RADIUS)


func _step_bumpers(dt: float) -> void:
	for b in bumpers:
		b.lit = maxf(b.lit - dt * 4.0, 0.0)
		var reach := Balance.BUMPER_RADIUS + Balance.SHIP_RADIUS
		if ship.pos.distance_squared_to(b.pos) < reach * reach:
			var away: Vector2 = (ship.pos - b.pos).normalized()
			ship.pos = b.pos + away * reach
			if ship.is_smasking():
				shock(b.pos, 60.0, 20.0)
				ship.vel = ship.vel.bounce(away)
			else:
				ship.vel = away * maxf(Balance.BUMPER_KICK, ship.vel.length())
			b.lit = 1.0
			fx.ring(b.pos, 20.0, 0.2, Color("fbf236"))
			fx.shake(2.0)
			sfx("bumper", -3.0, rng.randf_range(0.95, 1.1))
			rumble(0.4)
		for e in enemies:
			if not e.alive or not e.pushy:
				continue
			var r := Balance.BUMPER_RADIUS + e.radius
			if e.pos.distance_squared_to(b.pos) < r * r:
				var out: Vector2 = (e.pos - b.pos).normalized()
				e.pos = b.pos + out * r
				e.vel = out * 300.0
				e.damage(4.0, "shock")
				b.lit = 1.0


func _update_audio() -> void:
	if ship.state == Ship.State.DEAD or phase == Phase.OVER or phase == Phase.WAITING:
		Audio.set_engine(0.0, 1.0)
		return
	var speed := ship.speed_fraction()
	Audio.set_engine(0.03 + 0.1 * speed + 0.05 * ship.thrusting, 0.75 + speed * 0.8)
	var crowd := clampf(float(enemies.size()) / 22.0, 0.0, 1.0)
	var low := 0.3 if run.hull <= 1 else 0.0
	Audio.heat = clampf(crowd + low + (0.5 if boss != null else 0.0), 0.0, 1.0)


func _update_post() -> void:
	if _post_material == null:
		return
	var size := get_viewport_rect().size
	var data := PackedVector4Array()
	for r in fx.ripples:
		var at := to_screen(r.pos) / size
		data.append(Vector4(at.x, at.y, r.age / Fx.RIPPLE_LIFE, r.strength))
	while data.size() < 4:
		data.append(Vector4(0, 0, 1, 0))
	_post_material.set_shader_parameter("ripples", data)
	_post_material.set_shader_parameter("aspect", size.x / size.y)
	_post_material.set_shader_parameter("aberration", fx.aberration)
	_post_material.set_shader_parameter("flash_color", Color(fx.flash_color, fx.flash_amount))


# --- the drawing ---------------------------------------------------------------------


## How far the evening's gone, 0 to 1: the sky darkens and the colours deepen.
func _night() -> float:
	return clampf(float(run.hour_index) / float(Hours.EVENING.size() - 1), 0.0, 1.0)


func edge_color() -> Color:
	return Sprites.hsl(hue + 0.08, 0.8, 0.62 + fx.wall_hit * 0.35)


func _floor_color() -> Color:
	# The tile's a dark grey, so its colour's worked up well past white to show.
	var c := Sprites.hsl(hue, 0.55, lerpf(0.55, 0.32, _night()))
	return Color(c.r * 2.4, c.g * 2.4, c.b * 2.4)


func _paint_floor(c: CanvasItem) -> void:
	var view := get_viewport_rect().size
	var seen := Rect2(_camera.position - view * 0.5 - Vector2(16, 16), view + Vector2(32, 32))
	# The original's: the hue goes round for ever, and it's its colour that fills what's outside.
	var night := _night()
	c.draw_rect(seen, Sprites.hsl(hue, 0.25, lerpf(0.2, 0.08, night)))
	var tile_rect := arena
	var tint := _floor_color()
	c.draw_rect(tile_rect, Sprites.hsl(hue, 0.3, lerpf(0.13, 0.06, night)))
	c.draw_texture_rect(_floor_tile, tile_rect, true, tint)
	# The walls.
	var edge := edge_color()
	c.draw_rect(arena.grow(1.0), edge, false, 2.0)
	c.draw_rect(arena.grow(3.0), Color(edge, 0.3), false, 1.0)


func _paint_main(c: CanvasItem) -> void:
	# The shadows, all under everything.
	for b in bumpers:
		Sprites.draw(c, Sprites.get_tex("bumper1"), b.pos + Vector2(1, 3), 0.0, Color(0, 0, 0, 0.35))
	for e in enemies:
		e.draw_shadow(c)
	if ship.state != Ship.State.DEAD:
		Sprites.draw(c, Sprites.get_tex("ship1"), ship.pos + Vector2(2, 5), ship.angle + PI * 0.5, Color(0, 0, 0, 0.35))
	for b in bumpers:
		Sprites.draw(c, Sprites.get_tex("bumper2" if b.lit > 0.0 else "bumper1"), b.pos)
	fx.draw_smoke(c)
	pickups.draw(c)
	for w in _warnings:
		_paint_warning(c, w)
	for e in enemies:
		e.draw_under(c)
	for e in enemies:
		e.draw(c)
	shots.draw(c)
	missiles.draw(c)
	ship.draw(c)


func _paint_warning(c: CanvasItem, w: Dictionary) -> void:
	var radius := 3.0 + float(w.time) * 8.0
	c.draw_arc((w.pos as Vector2).round(), radius, 0.0, TAU, 12, Color(1, 1, 1, 0.8))
	if int(float(w.time) * 12.0) % 2 == 0:
		c.draw_rect(Rect2((w.pos as Vector2).round() - Vector2(1, 1), Vector2(2, 2)), Color("d95763"))


func _paint_add(c: CanvasItem) -> void:
	for e in enemies:
		e.draw_flash(c)
	if ship.is_smasking():
		var glow := Sprites.get_tex("glow")
		Sprites.draw(c, glow, ship.pos, 0.0, Color(1, 0.9, 0.3, 0.7), 1.6)
		Sprites.draw(c, Sprites.get_tex("ship3"), ship.pos, ship.angle + PI * 0.5, Color(1, 1, 1, 0.8))
	elif ship.state == Ship.State.CHARGING:
		Sprites.draw(c, Sprites.get_tex("ship3"), ship.pos, ship.angle + PI * 0.5, Color(1, 0.9, 0.3, ship.charge * 0.6))
	elif ship.invulnerable > 0.0 and ship.safe_from_smask and ship.state != Ship.State.DEAD:
		# Still safe: all gold, until it isn't.
		Sprites.draw(c, Sprites.get_tex("glow"), ship.pos, 0.0, Color(1, 0.9, 0.3, 0.5), 1.2)
		Sprites.draw(c, Sprites.get_tex("ship3"), ship.pos, ship.angle + PI * 0.5, Color(1, 0.85, 0.2, 0.85))
	elif ship.state == Ship.State.FLYING:
		Sprites.draw(c, Sprites.get_tex("glow"), ship.pos, 0.0, Color(0.6, 0.75, 1.0, 0.16), 1.2)
	fx.draw_add(c)


