extends Node
## The root: shows one screen at a time (the title, the game, the menus), fading
## through black between them.
##
## For testing without playing:
## `--screen=play` (or any screen's name) starts there, `--hour=5` starts the run
## on that hour of Hours, `--seed=3` fixes the seed, `--perks=twin,fuse` hands those
## out, `--mode=graveyard` picks the shift, `--autoplay` has the game play itself
## (`--invincible` so it can't lose), `--speed=4` runs it faster, `--shots=1.5,4,9`
## saves a screenshot to shots/ at each of those seconds (of game time) and quits
## after the last, `--shot-name=x` names them, `--size=1280x720` sizes the window,
## `--quit-after=60` quits after so many seconds, `--input-test` plays the controls
## by sending real input events (src/debug/input_test.gd), `--show=perks`,
## `--show=pause` or `--show=over` brings that up a moment into a run, `--deck` pretends to be a Steam
## Deck, and `--no-save` leaves the save alone.

const SCREENS := {
	"title": "res://src/ui/title.gd",
	"play": "res://src/play/play.gd",
	"options": "res://src/ui/options.gd",
	"help": "res://src/ui/help.gd",
	"scores": "res://src/ui/scores.gd",
	"ending": "res://src/ui/ending.gd",
	"credits": "res://src/ui/credits.gd",
}

var screen: Node
var screen_name := ""
var _wipe: Wipe
var _busy := false
var _shot_name := ""
var _cursor: Cursor


func _ready() -> void:
	Game.main = self
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.min_size = Vector2i(480, 270)
	_size_first_window()
	var fx_layer := CanvasLayer.new()
	fx_layer.layer = 90
	add_child(fx_layer)
	UI.fx = UiFx.new()
	fx_layer.add_child(UI.fx)
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_wipe = Wipe.new()
	layer.add_child(_wipe)
	_cursor = Cursor.new()
	layer.add_child(_cursor)
	var first := "title"
	var quit_after := -1.0
	var shots := []
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screen="):
			first = arg.trim_prefix("--screen=")
		elif arg.begins_with("--hour="):
			Game.start_hour = int(arg.trim_prefix("--hour="))
		elif arg.begins_with("--seed="):
			Game.fixed_seed = int(arg.trim_prefix("--seed="))
		elif arg.begins_with("--perks="):
			Game.start_perks = Array(arg.trim_prefix("--perks=").split(","))
		elif arg.begins_with("--mode="):
			Game.start_mode = arg.trim_prefix("--mode=")
		elif arg == "--autoplay":
			Game.autoplay = true
		elif arg == "--invincible":
			Game.invincible = true
		elif arg.begins_with("--speed="):
			Engine.time_scale = float(arg.trim_prefix("--speed="))
		elif arg.begins_with("--size="):
			var wh := arg.trim_prefix("--size=").split("x")
			get_window().size = Vector2i(int(wh[0]), int(wh[1]))
		elif arg.begins_with("--shot-name="):
			_shot_name = arg.trim_prefix("--shot-name=")
		elif arg.begins_with("--shots="):
			shots = Array(arg.trim_prefix("--shots=").split(",")).map(func(t: String) -> float: return float(t))
			Game.testing = true
		elif arg.begins_with("--show="):
			Game.debug_show = arg.trim_prefix("--show=")
		elif arg == "--input-test":
			Game.no_save = true
			add_child(preload("res://src/debug/input_test.gd").new())
		elif arg.begins_with("--quit-after="):
			quit_after = float(arg.trim_prefix("--quit-after="))
	show_screen(first)
	if not shots.is_empty():
		_take_shots(shots)
	if quit_after > 0.0:
		get_tree().create_timer(quit_after, true, false, true).timeout.connect(func() -> void:
			get_tree().quit())


## A first window that fits the screen, if the project's own doesn't.
func _size_first_window() -> void:
	if DisplayServer.get_name() == "headless" or OS.has_feature("web") or Game.settings.fullscreen:
		return
	var window := get_window()
	var room := DisplayServer.screen_get_usable_rect(window.current_screen).size
	if room.x <= 0 or room.y <= 0:
		return
	if window.size.x > room.x or window.size.y > room.y:
		var by := minf(float(room.x) / window.size.x, float(room.y) / window.size.y) * 0.95
		window.size = Vector2i(Vector2(window.size) * by)
		window.move_to_center()


func _take_shots(times: Array) -> void:
	# From the project, shots/ in it; from a build, wherever it can write.
	var folder := "res://shots" if OS.has_feature("editor") else "user://shots"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	# Kept out of the editor's imports (and so out of the builds).
	FileAccess.open(folder + "/.gdignore", FileAccess.WRITE)
	var clock := 0.0
	for t: float in times:
		while clock < t:
			await get_tree().process_frame
			clock += get_process_delta_time()
		await RenderingServer.frame_post_draw
		var name_part := _shot_name if _shot_name != "" else screen_name
		var path := folder + "/%s_%05.1f.png" % [name_part, t]
		get_viewport().get_texture().get_image().save_png(path)
		print("saved ", path)
	get_tree().quit()


## Shows the screen by that name. Its `open(args)`, if it has one, is given `args`.
func show_screen(which: String, args := {}, fade := 0.0) -> void:
	if _busy:
		return
	_busy = true
	var wiping := fade > 0.0 and screen != null
	if wiping:
		await _wipe.cover()
	if screen:
		screen.queue_free()
		screen = null
	get_tree().paused = false
	Audio.stop_sounds()
	var script: Script = load(SCREENS[which])
	screen = script.new()
	screen_name = which
	add_child(screen)
	if screen.has_method("open"):
		screen.open(args)
	_busy = false
	if wiping:
		_wipe.reveal()


func _process(_delta: float) -> void:
	_cursor.visible = Inputs.device == Inputs.Device.MOUSE
	_cursor.flying = screen_name == "play" and not get_tree().paused and not screen.get("_over")
	if Input.mouse_mode != Input.MOUSE_MODE_HIDDEN and DisplayServer.get_name() != "headless":
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _input(event: InputEvent) -> void:
	_rescue_focus(event)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_F11 or (event.physical_keycode == KEY_ENTER and event.alt_pressed):
			Game.toggle_fullscreen()
			get_viewport().set_input_as_handled()


## A click on nothing can leave no button chosen, and then a pad has nothing to
## move from. It gets the first one back.
func _rescue_focus(event: InputEvent) -> void:
	if get_viewport().gui_get_focus_owner() != null or screen == null:
		return
	for action in ["ui_up", "ui_down", "ui_left", "ui_right", "ui_accept"]:
		if event.is_action_pressed(action):
			var first := _first_button(screen)
			if first:
				first.grab_focus()
				get_viewport().set_input_as_handled()
			return


func _first_button(node: Node) -> Button:
	for child in node.get_children():
		if child is Button and child.is_visible_in_tree() and not child.disabled:
			return child
		var found := _first_button(child)
		if found:
			return found
	return null
