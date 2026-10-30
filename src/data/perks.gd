class_name Perks
## What you can pick up between the hours. `icon` is assets/sprites/perk_<id>.png;
## `most` is how many you can have of it.

const ALL := {
	"twin": {"name": "TWIN TUBES", "text": "Salvos reach two more targets.", "most": 3, "color": "5fcde4"},
	"warhead": {"name": "BIG WARHEADS", "text": "Missiles hit a third harder.", "most": 3, "color": "df7126"},
	"frag": {"name": "FRAGMENTS", "text": "Missiles burst, and hurt what's close.", "most": 2, "color": "fbf236"},
	"track": {"name": "GOOD MANNERS", "text": "Missiles fly through walls and turn tighter.", "most": 1, "color": "5fcde4"},
	"burn": {"name": "AFTERBURNER", "text": "A quarter more thrust.", "most": 2, "color": "df7126"},
	"slick": {"name": "SLICK HULL", "text": "A third less drag. A higher top speed.", "most": 2, "color": "639bff"},
	"bumper": {"name": "BUMPER KIT", "text": "Bounce off the walls instead of stopping.", "most": 1, "color": "99e550"},
	"ram": {"name": "SPEED KILLS", "text": "Flat out, you ram weak things to death.", "most": 1, "color": "cbdbfc"},
	"fuse": {"name": "SHORT FUSE", "text": "The SMASK charges 40% faster.", "most": 2, "color": "fbf236"},
	"long": {"name": "LONG SMASK", "text": "The SMASK goes further and hits harder.", "most": 2, "color": "fbf236"},
	"shock": {"name": "AFTERSHOCK", "text": "Every SMASK ends in a shock wave.", "most": 2, "color": "d95763"},
	"echo": {"name": "ECHO", "text": "Every SMASK fires a salvo at everything.", "most": 1, "color": "5fcde4"},
	"hull": {"name": "SPARE PLATING", "text": "One more hull, and all of it repaired.", "most": 3, "color": "639bff"},
	"second": {"name": "SECOND WIND", "text": "The hit that would end you doesn't, once.", "most": 1, "color": "d95763"},
	"magnet": {"name": "MAGNET", "text": "Coins come from twice as far.", "most": 1, "color": "ac3232"},
	"pay": {"name": "OVERTIME PAY", "text": "The multiplier holds on a second longer.", "most": 2, "color": "99e550"},
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
