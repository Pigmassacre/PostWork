extends Enemy
## 22:00, REPLY ALL. One big, furious envelope. Hit it enough and it doesn't die,
## it replies to everyone: two middling ones, and each of those gets three small
## ones, and the count on the floor goes UP. Rings of little mails all the while.

const SIZES := {
	3: {"sprite": "mail_big", "hp": 150.0, "radius": 13.0, "thrust": 40.0, "score": 1500, "coins": 10},
	2: {"sprite": "mail_mid", "hp": 60.0, "radius": 7.0, "thrust": 90.0, "score": 500, "coins": 4},
	1: {"sprite": "mail_small", "hp": 12.0, "radius": 4.0, "thrust": 170.0, "score": 150, "coins": 1},
}

var size := 3
var _next_at := 0.0
var _ring_turn := 0.0
var _cc_clock := 6.0


func enter() -> void:
	_become(3)
	pos = Vector2(0, world.arena.position.y + 40.0)
	world.remaining = 0
	world.add_enemy(self)


func _become(which: int) -> void:
	size = which
	kind = "mail"
	var def: Dictionary = SIZES[size]
	sprite = def.sprite
	max_hp = float(def.hp) * world.run.toughness()
	hp = max_hp
	radius = def.radius
	thrust = def.thrust
	score = def.score
	coins = def.coins
	pushy = size < 3
	_next_at = world.rng.randf_range(1.0, 2.0)


func is_boss_part() -> bool:
	return size >= 2


func think(dt: float) -> void:
	desired_angle = to_ship().angle()
	_next_at -= dt
	if _next_at <= 0.0:
		_shoot()
	if size == 3:
		_cc_clock -= dt
		if _cc_clock <= 0.0:
			_cc_clock = 7.0
			var cc := new_mail(1, pos)
			world.add_enemy(cc)
			world.sfx("spawn", -6.0)


func _shoot() -> void:
	match size:
		3:
			_next_at = 2.1
			_ring_turn += 0.31
			world.shots.ring(pos, 12, 62.0, "shot_mail", _ring_turn)
			world.sfx("shot", -6.0, 0.8)
			flash = 0.6
		2:
			_next_at = world.rng.randf_range(2.2, 3.0)
			for spread: float in [-0.25, 0.0, 0.25]:
				world.shots.fire(pos, to_ship().normalized().rotated(spread) * 85.0, "shot_mail")
			world.sfx("shot", -9.0)
		_:
			_next_at = 99.0


func new_mail(which: int, at: Vector2) -> Enemy:
	var mail: Enemy = get_script().new()
	mail.world = world
	mail.call("_become", which)
	mail.pos = at
	mail.vel = Vector2.from_angle(world.rng.randf() * TAU) * 180.0
	return mail


func on_death() -> void:
	if size <= 1:
		return
	var children := 2 if size == 3 else 3
	for i in children:
		world.add_enemy(new_mail(size - 1, pos))
	world.say_word("RE: RE: RE:" if size == 3 else "RE:", Color("cbdbfc"))
	world.sfx("reply", -2.0, 1.2 if size == 2 else 1.0)


func tex() -> Texture2D:
	return Sprites.get_tex("%s%d" % [sprite, 1 + int(age * 3.0) % 2])


func draw_rotation() -> float:
	return sin(age * 2.0) * 0.12
