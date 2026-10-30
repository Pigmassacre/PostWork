class_name Hours
## The evening, an hour at a time. Each is cleared by counting it down to zero:
## `waves` come in order, each when `gap` seconds have passed since the last or
## nearly everything on the floor is dead, whichever's first.
##
## `boss` names the script in src/play/bosses/, `feature` is "bumpers" or "shrink",
## `hint` is said when that wave arrives (once, ever).

const EVENING: Array[Dictionary] = [
	{"clock": 17, "name": "CLOCKING OUT", "arena": Vector2(300, 176), "music": "dusk", "waves": [
		{"spawn": {"froglet": 5}, "gap": 10.0, "hint": "fly"},
		{"spawn": {"froglet": 6}, "gap": 10.0},
		{"spawn": {"crab": 3, "froglet": 3}, "gap": 12.0},
		{"spawn": {"hermit": 1, "froglet": 3}, "gap": 14.0, "hint": "hermit"},
		{"spawn": {"crab": 5}, "gap": 10.0},
	]},
	{"clock": 18, "name": "THE CAR PARK", "arena": Vector2(340, 196), "music": "dusk", "waves": [
		{"spawn": {"starball": 3, "froglet": 4}, "gap": 10.0},
		{"spawn": {"tadpole": 12}, "gap": 8.0},
		{"spawn": {"crab": 5, "starball": 2}, "gap": 11.0},
		{"spawn": {"hermit": 2, "tadpole": 8}, "gap": 11.0},
		{"spawn": {"crab": 4, "froglet": 6, "starball": 2}, "gap": 10.0},
	]},
	{"clock": 19, "name": "THE COMMUTE", "arena": Vector2(420, 232), "music": "boss", "boss": "commute", "waves": []},
	{"clock": 20, "name": "LEFTOVERS", "arena": Vector2(380, 216), "music": "night", "feature": "bumpers", "waves": [
		{"spawn": {"spawn": 2, "froglet": 4}, "gap": 14.0, "hint": "bumpers"},
		{"spawn": {"squid": 3, "crab": 4}, "gap": 12.0},
		{"spawn": {"tadpole": 14, "hermit": 1}, "gap": 10.0},
		{"spawn": {"spawn": 2, "squid": 3, "starball": 3}, "gap": 14.0},
		{"spawn": {"crab": 8, "hermit": 2}, "gap": 10.0},
	]},
	{"clock": 21, "name": "ONE MORE EPISODE", "arena": Vector2(420, 232), "music": "night", "feature": "bumpers", "waves": [
		{"spawn": {"urchin": 4, "tadpole": 8}, "gap": 11.0},
		{"spawn": {"squid": 4, "starball": 4}, "gap": 12.0},
		{"spawn": {"urchin": 4, "crab": 6, "hermit": 1}, "gap": 12.0},
		{"spawn": {"spawn": 3, "squid": 3}, "gap": 13.0},
		{"spawn": {"tadpole": 16, "starball": 4, "hermit": 2}, "gap": 10.0},
		{"spawn": {"urchin": 5, "crab": 8}, "gap": 10.0},
	]},
	{"clock": 22, "name": "REPLY ALL", "arena": Vector2(440, 236), "music": "boss", "boss": "reply_all", "waves": []},
	{"clock": 23, "name": "CAN'T SLEEP", "arena": Vector2(460, 240), "music": "late", "feature": "shrink", "waves": [
		{"spawn": {"crab": 8, "starball": 4}, "gap": 10.0, "hint": "shrink"},
		{"spawn": {"squid": 5, "urchin": 4, "hermit": 1}, "gap": 11.0},
		{"spawn": {"spawn": 3, "tadpole": 12}, "gap": 11.0},
		{"spawn": {"hermit": 3, "crab": 8}, "gap": 10.0},
		{"spawn": {"urchin": 5, "squid": 5, "starball": 5}, "gap": 11.0},
		{"spawn": {"tadpole": 24, "crab": 8, "hermit": 2}, "gap": 10.0},
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
