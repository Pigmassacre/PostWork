extends Node
## A run: the world, the HUD over it, and what comes up between the hours.

const POST_SHADER := preload("res://src/fx/post.gdshader")

var world: World
var run: Run
var _hud: Hud
var _pause: PauseMenu
var _ui: Control
var _view: GameView
var _post: ShaderMaterial
var _over := false


func open(args: Dictionary) -> void:
	# The root keeps running under a pause; this mustn't.
	process_mode = Node.PROCESS_MODE_PAUSABLE
	run = Game.new_run(args.get("mode", Run.EVENING))
	_view = GameView.new()
	add_child(_view)
	world = World.new()
	world.setup(run)
	world.hour_cleared.connect(_on_hour_cleared)
	world.ship_dead.connect(_on_ship_dead)
	world.evening_over.connect(_on_evening_over)
	world.hint_wanted.connect(_on_hint)
	_post = ShaderMaterial.new()
	_post.shader = POST_SHADER
	_view.add_post(_post)
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	_ui = Control.new()
	_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_ui)
	_hud = Hud.new()
	_hud.world = world
	_hud.view = _view
	_ui.add_child(_hud)
	world.banner_wanted.connect(_hud.banner)
	_view.show_world(world)
	world.set_post_material(_post)
	if Inputs.device == Inputs.Device.TOUCH or DisplayServer.is_touchscreen_available():
		_ui.add_child(TouchControls.new())
	_pause = PauseMenu.new()
	_pause.visible = false
	_ui.add_child(_pause)
	if Game.debug_show != "":
		await get_tree().create_timer(4.0).timeout
		if Game.debug_show == "pause":
			_pause.open()
		elif Game.debug_show == "perks":
			world.phase = World.Phase.WAITING
			_on_hour_cleared()
		elif Game.debug_show == "over":
			run.hull = 1
			world.ship.invulnerable = 0.0
			world.ship.hurt(world.ship.pos + Vector2.ONE)
		elif Game.debug_show == "pickups":
			world.pickups.drop_coffee(world.ship.pos + Vector2(40, 0))
			for i in 8:
				world.pickups.drop_coin(world.ship.pos + Vector2(-30, 20) + Vector2.from_angle(i * 0.8) * 10.0)
		elif Game.debug_show == "smask":
			world.ship.state = Ship.State.CHARGING
			world.ship.charge = 1.0
			world.ship._let_go()


func _exit_tree() -> void:
	Audio.set_engine(0.0, 1.0)
	Inputs.touch_move = Vector2.ZERO
	Inputs.touch_smask = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and _can_pause():
		get_viewport().set_input_as_handled()
		_pause.open()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and _pause and _can_pause() and not Game.autoplay and not Game.testing:
		_pause.open()


func _can_pause() -> bool:
	return not _over and not get_tree().paused and world.phase != World.Phase.WAITING


func _on_hint(id: String) -> void:
	if not Game.hint_once(id):
		return
	var text := ""
	match id:
		"fly":
			text = "%s TO FLY. GUNS FIRE THEMSELVES." % Inputs.prompt("move").to_upper()
		"hermit":
			text = "SHELLS BLOCK MISSILES. HOLD %s, RELEASE TO SMASK." % Inputs.prompt("smask").to_upper()
		"bumpers":
			text = "BUMPERS BOOST YOU."
		"shrink":
			text = "WALLS CLOSING IN."
	_hud.hint(text, 7.0)


func _on_hour_cleared() -> void:
	# The next hour's clock is on the card: past the last there's no card.
	var last: bool = run.mode == Run.EVENING and run.hour_index + 1 >= Hours.EVENING.size()
	if last:
		world.next_hour()
		return
	var pick := PerkPick.new()
	pick.picked.connect(func(id: String) -> void:
		if id != "":
			run.add_perk(id)
		world.next_hour()
	)
	_ui.add_child(pick)
	pick.offer(run)


func _on_ship_dead() -> void:
	_over = true
	var place := Game.record_run(run, false)
	print("died at ", run.clock_now(), " score ", run.score, " kills ", run.kills, " time ", run.time)
	await get_tree().create_timer(1.6).timeout
	if not is_inside_tree():
		return
	Audio.muffle(0.6)
	var over := GameOver.new()
	_ui.add_child(over)
	over.show_for(run, place)
	tree_exiting.connect(func() -> void: Audio.muffle(0.0))
	if Game.autoplay:
		get_tree().quit()


func _on_evening_over() -> void:
	_over = true
	Game.record_run(run, true)
	print("won, score ", run.score, " kills ", run.kills, " time ", run.time)
	Game.main.show_screen("ending", {"run": run}, 1.2)
