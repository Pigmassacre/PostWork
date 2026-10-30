extends Node
## What lasts between games: the settings, the best runs, the run being played.
## Saved in user://supersmaskzero.cfg.

signal settings_changed

const SAVE_PATH := "user://supersmaskzero.cfg"
const HIGH_SCORES := 10

const DEFAULTS := {
	"music": 0.7,
	"sounds": 0.8,
	"shake": 1.0,
	"flashes": true,
	"spare_hull": false,
	"fullscreen": false,
	"rumble": true,
}

var settings := DEFAULTS.duplicate()
## The best runs, best first: {"score", "hour", "time", "won", "mode", "date"}.
var high_scores: Array = []
var runs_played := 0
## Runs that have seen midnight off; the first opens the Graveyard Shift.
var wins := 0
## The hints already given, so they're given once.
var hints_seen: Array = []

## The run being played.
var run: Run
## The root (main.gd), that swaps the screens.
var main: Node

## For testing without playing: the game plays itself (`--autoplay`, src/debug/autopilot.gd).
var autoplay := false
var invincible := false
## `--hour=3` starts the run on that hour of Hours.
var start_hour := 0
## `--perks=twin,fuse` hands those out at the start.
var start_perks: Array = []
## `--seed=5` a fixed seed.
var fixed_seed := -1
## `--mode=graveyard` starts on that shift.
var start_mode := ""
## `--no-save`: for a test that plays like a person, without touching their save.
var no_save := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_save()
	apply_settings()


func load_save() -> void:
	# On a Steam Deck, full screen, till the player says otherwise.
	if Inputs.deck:
		settings.fullscreen = true
	var args := OS.get_cmdline_user_args()
	no_save = args.has("--no-save")
	var cfg := ConfigFile.new()
	if not no_save and cfg.load(SAVE_PATH) == OK:
		for key: String in DEFAULTS:
			settings[key] = cfg.get_value("settings", key, settings[key])
		high_scores = cfg.get_value("scores", "high_scores", [])
		runs_played = cfg.get_value("scores", "runs_played", 0)
		wins = cfg.get_value("scores", "wins", 0)
		hints_seen = cfg.get_value("progress", "hints_seen", [])
	# A test asking for a window size means a window.
	for arg in args:
		if arg.begins_with("--size="):
			settings.fullscreen = false


func save() -> void:
	# A test run leaves the player's save alone.
	if autoplay or no_save:
		return
	var cfg := ConfigFile.new()
	for key: String in settings:
		cfg.set_value("settings", key, settings[key])
	cfg.set_value("scores", "high_scores", high_scores)
	cfg.set_value("scores", "runs_played", runs_played)
	cfg.set_value("scores", "wins", wins)
	cfg.set_value("progress", "hints_seen", hints_seen)
	cfg.save(SAVE_PATH)


func apply_settings() -> void:
	Audio.set_volume(Audio.MUSIC, float(settings.music))
	Audio.set_volume(Audio.SOUNDS, float(settings.sounds))
	if not (OS.has_feature("web") or DisplayServer.get_name() == "headless"):
		var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if settings.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
		if DisplayServer.window_get_mode() != mode:
			DisplayServer.window_set_mode(mode)
	settings_changed.emit()


func toggle_fullscreen() -> void:
	settings.fullscreen = not settings.fullscreen
	apply_settings()
	save()


func new_run(mode := Run.EVENING) -> Run:
	if start_mode == "graveyard":
		mode = Run.GRAVEYARD
	run = Run.new()
	var chosen := fixed_seed if fixed_seed >= 0 else randi()
	run.start(mode, chosen, start_hour)
	for perk: String in start_perks:
		run.add_perk(perk)
	runs_played += 1
	return run


## Puts the run in the books. Returns its place in the table (from 0), or -1.
func record_run(the_run: Run, won: bool) -> int:
	if won:
		wins += 1
	var entry := {
		"score": the_run.score,
		"hour": the_run.clock_now(),
		"time": the_run.time,
		"won": won,
		"mode": the_run.mode,
		"date": Time.get_date_string_from_system(),
	}
	var place := -1
	# With the spare hull on it's not a competition.
	if not the_run.spare_hull:
		for i in high_scores.size():
			if the_run.score > int(high_scores[i].score):
				place = i
				break
		if place < 0 and high_scores.size() < HIGH_SCORES:
			place = high_scores.size()
		if place >= 0:
			high_scores.insert(place, entry)
			high_scores.resize(mini(high_scores.size(), HIGH_SCORES))
	save()
	return place


func best_score() -> int:
	return 0 if high_scores.is_empty() else int(high_scores[0].score)


## Says a hint once, ever. True if it's new.
func hint_once(id: String) -> bool:
	if hints_seen.has(id):
		return false
	hints_seen.append(id)
	save()
	return true


## "v1.0 abcdef": the version and the commit, for the title. A build has the
## commit in commit.txt; from the project, git knows it.
func version_text() -> String:
	var version: String = ProjectSettings.get_setting("application/config/version", "")
	var commit := ""
	if FileAccess.file_exists("res://commit.txt"):
		commit = FileAccess.get_file_as_string("res://commit.txt").strip_edges()
	elif OS.has_feature("editor") and not OS.has_feature("web"):
		var out := []
		if OS.execute("git", ["-C", ProjectSettings.globalize_path("res://"), "rev-parse", "--short", "HEAD"], out) == 0 and not out.is_empty():
			commit = String(out[0]).strip_edges()
	return "v%s %s" % [version, commit]
