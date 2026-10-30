class_name Run
extends RefCounted
## One evening: the hour it's got to, the hull, the score, the perks taken.

const EVENING := "evening"
const GRAVEYARD := "graveyard"

var mode := EVENING
var rng := RandomNumberGenerator.new()
var hour_index := 0
var hull := Balance.START_HULL
var max_hull := Balance.START_HULL
var score := 0
var kills := 0
var time := 0.0
var combo := 0
var combo_time := 0.0
var perks := {}
var second_wind_used := false
var spare_hull := false
## Hits taken this hour, for the bonus.
var hits_this_hour := 0
var hour_time := 0.0
## The clock's minutes, 0 to 59: how far through the hour's count it's got.
var minutes := 0


func start(the_mode: String, the_seed: int, first_hour: int) -> void:
	mode = the_mode
	rng.seed = the_seed
	hour_index = first_hour + (Hours.EVENING.size() if mode == GRAVEYARD else 0)
	spare_hull = Game.settings.spare_hull
	if spare_hull:
		max_hull += 2
		hull = max_hull


func hour() -> Dictionary:
	return Hours.at(hour_index)


func clock_now() -> String:
	return Hours.clock_text(int(hour().clock), minutes)


func has(perk: String) -> bool:
	return int(perks.get(perk, 0)) > 0


func level(perk: String) -> int:
	return int(perks.get(perk, 0))


func add_perk(perk: String) -> void:
	perks[perk] = level(perk) + 1
	if perk == "hull":
		max_hull = mini(max_hull + 1, Balance.MAX_HULL)
		hull = max_hull


func multiplier() -> int:
	return mini(1 + combo / Balance.COMBO_PER_STEP, Balance.MULTIPLIER_MAX)


func combo_limit() -> float:
	return Balance.COMBO_TIME + level("pay") * 1.0


func add_kill(points: int) -> int:
	kills += 1
	combo += 1
	combo_time = combo_limit()
	var earned := points * multiplier()
	score += earned
	return earned


func tick(dt: float) -> void:
	time += dt
	hour_time += dt
	if combo > 0:
		combo_time -= dt
		if combo_time <= 0.0:
			# It falls a step at a time, not all at once.
			combo = maxi(combo - Balance.COMBO_PER_STEP, 0)
			combo_time = combo_limit() * 0.5


## What the hour past midnight makes everything's health worth.
func toughness() -> float:
	return 1.0 + float(hour().get("past", 0)) * Balance.GRAVEYARD_HP


func crowding() -> float:
	return 1.0 + float(hour().get("past", 0)) * Balance.GRAVEYARD_COUNT
