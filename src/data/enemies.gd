class_name Enemies
## What's out there. `sprite` is in assets/sprites, with frames 1 and 2.

const KINDS := {
	"froglet": {"sprite": "froglet", "hp": 6.0, "radius": 4.0, "score": 100, "thrust": 0.0, "coin": 1},
	# The original's enemy, as it was: its propel of 2 and its health of 10.
	"crab": {"sprite": "yellowcrab", "hp": 10.0, "radius": 4.0, "score": 150, "thrust": 120.0, "coin": 1},
	"starball": {"sprite": "starball", "hp": 8.0, "radius": 4.0, "score": 200, "thrust": 0.0, "coin": 2},
	"tadpole": {"sprite": "tadpole", "hp": 2.0, "radius": 3.0, "score": 40, "thrust": 230.0, "coin": 0},
	"spawn": {"sprite": "frogspawn", "hp": 46.0, "radius": 8.0, "score": 500, "thrust": 0.0, "coin": 6},
	"squid": {"sprite": "squid", "hp": 14.0, "radius": 4.0, "score": 250, "thrust": 110.0, "coin": 2},
	"urchin": {"sprite": "urchin", "hp": 18.0, "radius": 5.0, "score": 250, "thrust": 26.0, "coin": 2},
	"hermit": {"sprite": "hermit", "hp": 10.0, "radius": 6.0, "score": 400, "thrust": 62.0, "coin": 4},
}
