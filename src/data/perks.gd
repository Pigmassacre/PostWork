class_name Perks
## What you can pick up between the hours. `icon` is assets/sprites/perk_<id>.png;
## `most` is how many you can have of it.

const ALL := {
	"twin": {"name": "TWIN TUBES", "text": "+1 target per salvo", "most": 3, "color": "5fcde4"},
	"warhead": {"name": "BIG WARHEADS", "text": "+33% missile damage", "most": 3, "color": "df7126"},
	"frag": {"name": "FRAG ROUNDS", "text": "Missiles explode", "most": 2, "color": "fbf236"},
	"track": {"name": "GHOST MISSILES", "text": "Missiles ignore walls", "most": 1, "color": "5fcde4"},
	"burn": {"name": "AFTERBURNER", "text": "+25% thrust", "most": 2, "color": "df7126"},
	"slick": {"name": "SLICK HULL", "text": "-33% drag", "most": 2, "color": "639bff"},
	"bumper": {"name": "BUMPER KIT", "text": "Bounce off walls", "most": 1, "color": "99e550"},
	"ram": {"name": "SPEED KILLS", "text": "Ram weak enemies at top speed", "most": 1, "color": "cbdbfc"},
	"fuse": {"name": "SHORT FUSE", "text": "Charge 40% faster", "most": 2, "color": "fbf236"},
	"long": {"name": "LONG SMASK", "text": "+30% SMASK range and damage", "most": 2, "color": "fbf236"},
	"shock": {"name": "AFTERSHOCK", "text": "SMASK ends in a shockwave", "most": 2, "color": "d95763"},
	"echo": {"name": "ECHO", "text": "SMASK fires a salvo", "most": 1, "color": "5fcde4"},
	"hull": {"name": "SPARE PLATING", "text": "+1 hull. Full repair", "most": 3, "color": "639bff"},
	"second": {"name": "SECOND WIND", "text": "Survive one fatal hit", "most": 1, "color": "d95763"},
	"magnet": {"name": "MAGNET", "text": "Double coin range", "most": 1, "color": "ac3232"},
	"pay": {"name": "OVERTIME PAY", "text": "Multiplier lasts +1s", "most": 2, "color": "99e550"},
}


## `count` different perks that `taken` (id: how many) leaves on offer.
static func offer(taken: Dictionary, count: int, rng: RandomNumberGenerator) -> Array:
	var open: Array = []
	for id: String in ALL:
		if int(taken.get(id, 0)) < int(ALL[id].most):
			open.append(id)
	# Shuffled by the run's own generator, for a fixed seed's tests.
	for i in range(open.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: String = open[i]
		open[i] = open[j]
		open[j] = swap
	return open.slice(0, count)
