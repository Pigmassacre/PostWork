class_name Hours
## The evening, an hour at a time. Each is cleared by counting it down to zero:
## `waves` come in order, each when `gap` seconds have passed since the last or
## nearly everything on the floor is dead, whichever's first.
##
## `boss` names the script in src/play/bosses/, `feature` is "bumpers" or "shrink",
## `hint` is said when that wave arrives (once, ever).

const EVENING: Array[Dictionary] = [
	{"clock": 17, "name": "CLOCKING OUT", "arena": Vector2(350, 204), "music": "dusk", "waves": [
		{"spawn": {"froglet": 5}, "gap": 12.0, "hint": "fly"},
		{"spawn": {"froglet": 7}, "gap": 11.0},
		{"spawn": {"crab": 4, "froglet": 4}, "gap": 12.0},
		{"spawn": {"hermit": 1, "froglet": 3}, "gap": 16.0, "hint": "hermit"},
		{"spawn": {"crab": 8}, "gap": 10.0},
	]},
	{"clock": 18, "name": "THE CAR PARK", "arena": Vector2(380, 216), "music": "dusk", "waves": [
		{"spawn": {"starball": 4, "froglet": 6}, "gap": 10.0},
		{"spawn": {"tadpole": 18}, "gap": 8.0},
		{"spawn": {"crab": 8, "starball": 3}, "gap": 11.0},
		{"spawn": {"hermit": 3, "tadpole": 12}, "gap": 11.0},
		{"spawn": {"crab": 6, "froglet": 9, "starball": 3}, "gap": 10.0},
	]},
	{"clock": 19, "name": "THE COMMUTE", "arena": Vector2(420, 232), "music": "boss", "boss": "commute", "waves": []},
	{"clock": 20, "name": "LEFTOVERS", "arena": Vector2(400, 224), "music": "night", "feature": "bumpers", "waves": [
		{"spawn": {"spawn": 3, "froglet": 6}, "gap": 14.0, "hint": "bumpers"},
		{"spawn": {"squid": 4, "crab": 6}, "gap": 12.0},
		{"spawn": {"tadpole": 21, "hermit": 2}, "gap": 10.0},
		{"spawn": {"spawn": 3, "squid": 4, "starball": 4}, "gap": 14.0},
		{"spawn": {"crab": 12, "hermit": 3}, "gap": 10.0},
	]},
	{"clock": 21, "name": "ONE MORE EPISODE", "arena": Vector2(420, 232), "music": "night", "feature": "bumpers", "waves": [
		{"spawn": {"urchin": 6, "tadpole": 12}, "gap": 11.0},
		{"spawn": {"squid": 6, "starball": 6}, "gap": 12.0},
		{"spawn": {"urchin": 6, "crab": 9, "hermit": 2}, "gap": 12.0},
		{"spawn": {"spawn": 4, "squid": 4}, "gap": 13.0},
		{"spawn": {"tadpole": 24, "starball": 6, "hermit": 3}, "gap": 10.0},
		{"spawn": {"urchin": 8, "crab": 12}, "gap": 10.0},
	]},
	{"clock": 22, "name": "REPLY ALL", "arena": Vector2(440, 236), "music": "boss", "boss": "reply_all", "waves": []},
	{"clock": 23, "name": "CAN'T SLEEP", "arena": Vector2(460, 240), "music": "late", "feature": "shrink", "waves": [
		{"spawn": {"crab": 12, "starball": 6}, "gap": 10.0, "hint": "shrink"},
		{"spawn": {"squid": 8, "urchin": 6, "hermit": 2}, "gap": 11.0},
		{"spawn": {"spawn": 4, "tadpole": 18}, "gap": 11.0},
		{"spawn": {"hermit": 4, "crab": 12}, "gap": 10.0},
		{"spawn": {"urchin": 8, "squid": 8, "starball": 8}, "gap": 11.0},
		{"spawn": {"tadpole": 36, "crab": 12, "hermit": 3}, "gap": 10.0},
	]},
	{"clock": 0, "name": "OVERTIME", "arena": Vector2(460, 240), "music": "final", "boss": "overtime", "waves": []},
]


## The hour at `index` of a run. Past midnight, on the graveyard shift, the
## evening comes round again, a little worse each time.
static func at(index: int) -> Dictionary:
	if index < EVENING.size():
		return EVENING[index]
	var past := index - EVENING.size()
	var rerun: Dictionary = EVENING[[0, 1, 3, 2, 4, 6, 5][past % 7]].duplicate(true)
	rerun.clock = (past + 1) % 24
	rerun.feature = rerun.get("feature", ["", "bumpers", "shrink"][past % 3])
	rerun.past = past + 1
	if not rerun.has("boss"):
		rerun.music = ["night", "late"][past % 2]
	return rerun


static func clock_text(hour: int, minute := 0) -> String:
	return "%02d:%02d" % [hour, minute]
