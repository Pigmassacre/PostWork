extends Node
## Plays the game through its real input (`--input-test`): from the title, by
## keyboard, through a hour's start, flying, charging, SMASKing, pausing, the
## pause menu and back out, and says what it saw. Exits with 1 if anything's wrong.

var _failed := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run.call_deferred()


func _check(ok: bool, what: String) -> void:
	print(("ok   " if ok else "FAIL ") + what)
	if not ok:
		_failed += 1


func _key(key: Key, down: bool) -> void:
	var e := InputEventKey.new()
	e.physical_keycode = key
	e.keycode = key
	e.pressed = down
	Input.parse_input_event(e)
	Input.flush_buffered_events()


func _tap(key: Key) -> void:
	_key(key, true)
	await _wait(0.1)
	_key(key, false)
	await _wait(0.1)


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds, true, false, true).timeout


func _run() -> void:
	var main: Node = Game.main
	Game.invincible = true
	Game.testing = true
	await _wait(0.6)
	_check(main.screen_name == "title", "starts on the title")
	_check(get_viewport().gui_get_focus_owner() != null, "the title has a button chosen")
	await _tap(KEY_SPACE)
	await _wait(0.8)
	_check(main.screen_name == "play", "the first button starts a run")
	var world: World = main.screen.world
	var ship: Ship = world.ship
	var start := ship.pos
	_key(KEY_D, true)
	await _wait(0.6)
	_check(ship.vel.x > 60.0, "D thrusts right (%.0f)" % ship.vel.x)
	_check(absf(angle_difference(ship.angle, 0.0)) < 0.2, "and it turns that way")
	_key(KEY_D, false)
	await _wait(0.4)
	_check(ship.pos.x > start.x + 20.0, "it drifts on after letting go")
	_key(KEY_SPACE, true)
	await _wait(0.45)
	_check(ship.state == Ship.State.CHARGING, "holding Space charges")
	_check(ship.vel.length() <= Balance.CHARGE_SPEED_LIMIT + 60.0, "and brakes (%.0f)" % ship.vel.length())
	_key(KEY_SPACE, false)
	await _wait(0.03)
	_check(ship.state == Ship.State.SMASKING, "letting go SMASKs")
	await _wait(0.9)
	_check(ship.state == Ship.State.FLYING, "and then it's flying again")
	await _wait(2.5)
	_check(world.phase == World.Phase.FIGHT, "the fight starts")
	await _wait(1.8)
	_check(world.enemies.size() > 0 or world.run.kills > 0, "things have turned up (%d on the floor, %d killed, phase %d)" % [world.enemies.size(), world.run.kills, world.phase])
	await _wait(2.0)
	var before: int = world.run.score + world.run.kills
	await _wait(3.0)
	_check(world.missiles.count > 0 or world.run.score + world.run.kills > before, "the guns are at it")
	_tap(KEY_ESCAPE)
	await _wait(0.3)
	_check(get_tree().paused, "Esc pauses")
	var frozen := ship.pos
	await _wait(0.3)
	_check(frozen == ship.pos, "and everything stops")
	_tap(KEY_ESCAPE)
	await _wait(0.3)
	_check(not get_tree().paused, "Esc again carries on")
	_tap(KEY_ESCAPE)
	await _wait(0.3)
	await _tap(KEY_S)
	await _tap(KEY_S)
	await _tap(KEY_SPACE)
	await _wait(1.0)
	_check(main.screen_name == "title", "the pause menu's last button goes to the title")
	print("input test: %d failed" % _failed)
	get_tree().quit(1 if _failed > 0 else 0)
