extends MenuScreen
## The best evenings so far.


func _ready() -> void:
	build("BEST EVENINGS")
	if Game.high_scores.is_empty():
		var none := UI.label("Nothing yet. Go on, it's after work.", UI.DIM)
		none.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		body.add_child(none)
	for i in Game.high_scores.size():
		var entry: Dictionary = Game.high_scores[i]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		body.add_child(row)
		var color := UI.ACCENT if entry.get("won", false) else UI.SOFT
		var place := UI.label("%2d" % (i + 1), UI.DIM)
		place.custom_minimum_size.x = 16
		row.add_child(place)
		var score := UI.label(UI.format_score(int(entry.score)), color)
		score.custom_minimum_size.x = 70
		row.add_child(score)
		var hour := UI.label(str(entry.get("hour", "")), UI.SOFT)
		hour.custom_minimum_size.x = 36
		row.add_child(hour)
		var time := UI.label(UI.format_time(float(entry.get("time", 0.0))), UI.DIM)
		time.custom_minimum_size.x = 36
		row.add_child(time)
		var note := "MIDNIGHT" if entry.get("won", false) else ""
		if entry.get("mode", "") == Run.GRAVEYARD:
			note = "GRAVEYARD"
		row.add_child(UI.label(note, UI.ACCENT))
		row.add_child(UI.label(str(entry.get("date", "")), UI.FAINT))
