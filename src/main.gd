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
## by sending real input events (src/debug/input_test.gd), `--show=perks` or
## `--show=over` brings that up a moment into a run, `--deck` pretends to be a Steam
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

const BASE_SIZE := Vector2(480, 270)

var screen: Node
var screen_name := ""
var _fade: ColorRect
var _busy := false
var _shot_name := ""
var _fitted_to := Vector2.ZERO
var _cursor: TextureRect


func _ready() -> void:
	Game.main = self
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.min_size = Vector2i(480, 270)
	_size_first_window()
	_fit_window()
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_fade = ColorRect.new()
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fade.color = Color(0, 0, 0, 0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_fade)
	# The pointer is drawn in the game's own pixels, like everything else.
	_cursor = TextureRect.new()
	_cursor.texture = load("res://assets/sprites/pointer.png")
	_cursor.mouse_filter = Control.MOUSE_FILTER_IGNORE
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


## The game's pixels are always a whole number of the window's, however big the
## window is: at least 480 by 270 of them, and however many more fit.
func _fit_window() -> void:
	var root := get_tree().root
	var window := Vector2(root.size)
	if window == _fitted_to or window.x <= 0.0 or window.y <= 0.0:
		return
	_fitted_to = window
	var by := maxf(1.0, floorf(minf(window.x / BASE_SIZE.x, window.y / BASE_SIZE.y)))
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_IGNORE
	root.content_scale_size = Vector2i(floori(window.x / by), floori(window.y / by))


## A first window of the biggest whole multiple of the game that fits the screen, up to the project's.
func _size_first_window() -> void:
	if DisplayServer.get_name() == "headless" or OS.has_feature("web") or Game.settings.fullscreen:
		return
	var window := get_window()
	var room := Vector2(DisplayServer.screen_get_usable_rect(window.current_screen).size)
	if room.x <= 0.0 or room.y <= 0.0:
		return
	var by := maxf(1.0, floorf(minf(room.x / BASE_SIZE.x, room.y / BASE_SIZE.y)))
	var fits := Vector2i(BASE_SIZE * by)
	if fits.x < window.size.x or fits.y < window.size.y:
		window.size = fits
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
	if fade > 0.0 and screen != null:
		var t := create_tween()
		t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		t.tween_property(_fade, "color:a", 1.0, fade)
		await t.finished
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
	if fade > 0.0:
		var t := create_tween()
		t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		t.tween_property(_fade, "color:a", 0.0, fade)
	else:
		_fade.color.a = 0.0


func _process(_delta: float) -> void:
	_fit_window()
	var flying: bool = screen_name == "play" and not get_tree().paused and not screen.get("_over")
	_cursor.visible = Inputs.device == Inputs.Device.MOUSE
	if flying and _cursor.visible:
		_cursor.modulate = Color(1, 1, 1, 0.8)
	else:
		_cursor.modulate = Color.WHITE
	if Input.mouse_mode != Input.MOUSE_MODE_HIDDEN and DisplayServer.get_name() != "headless":
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_cursor.position = get_viewport().get_mouse_position().round()


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
