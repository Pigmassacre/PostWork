extends MenuScreen
## The best evenings so far.


func _ready() -> void:
	build("HIGH SCORES", false)
	var rows := ScoreRows.new()
	rows.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	body.add_child(rows)


class ScoreRows extends Control:
	var _time := 0.0

	func _process(delta: float) -> void:
		_time += delta
		queue_redraw()

	func _draw() -> void:
		if Game.high_scores.is_empty():
			UI.centred(self, UI.display_font(), size * 0.5 - Vector2(0, 40), "NO SCORES YET", 40, UI.WHITE, 16)
			return
		var height := 66.0
		for i in Game.high_scores.size():
			var entry: Dictionary = Game.high_scores[i]
			var k := UI.back_out((_time - i * 0.05) / 0.3)
			if _time < i * 0.05:
				continue
			var won: bool = entry.get("won", false)
			var graveyard: bool = entry.get("mode", "") == Run.GRAVEYARD
			var at := Vector2(i * -7.0 + (1.0 - k) * -1800.0, i * (height + 4.0))
			var r := Rect2(at, Vector2(size.x, height))
			var first := i == 0
			UI.slab(self, r, UI.YELLOW if first else UI.INK, 0.2)
			var ink := UI.INK if first else UI.WHITE
			var mid_y := at.y + height * 0.5 + 14.0
			UI.outlined(self, UI.title_font(), Vector2(at.x + 22.0, mid_y + 4.0), str(i + 1), 44, UI.PINK if not first else UI.INK)
			UI.outlined(self, UI.title_font(), Vector2(at.x + 110.0, mid_y + 4.0), UI.format_score(int(entry.score)), 48, ink)
			UI.outlined(self, UI.title_font(), Vector2(at.x + 660.0, mid_y + 4.0), str(entry.get("hour", "")), 44, ink if first else UI.CYAN)
			UI.outlined(self, UI.body_font(), Vector2(at.x + 900.0, mid_y), UI.format_time(float(entry.get("time", 0.0))), 30, ink)
			var note := "GRAVEYARD" if graveyard else ("WON" if won else "")
			UI.outlined(self, UI.display_font(), Vector2(at.x + 1030.0, mid_y), note, 26, UI.INK if first else UI.YELLOW)
			UI.outlined(self, UI.body_font(), Vector2(at.x + size.x - 240.0, mid_y), str(entry.get("date", "")), 26, ink if first else UI.DIM)
