extends MenuScreen
## How to play: six cards, each with a sprite from the game, blown up.

const CARD := Vector2(540, 340)


func _ready() -> void:
	build("HOW TO PLAY", false)
	var move := Inputs.prompt("move").to_upper()
	var smask := Inputs.prompt("smask").to_upper()
	var cards := [
		["FLY", "%s to steer. You drift. Speed is power." % move, "ship3", UI.BLUE],
		["AUTO-FIRE", "Guns aim themselves. Faster flying, harder hits.", "starball1", UI.CYAN],
		["CHARGE", "Hold %s. Guns stop. Time slows. Longer hits harder and flies further." % smask, "ship4", UI.ORANGE],
		["SMASK", "Release to ram. Gold means safe. Kills reset it. Walls explode.", "yellowcrab1", UI.YELLOW],
		["SHELLS", "Missiles bounce off. SMASK breaks them.", "hermit1", UI.SOFT],
		["ZERO", "The floor shows what's left. Hit zero. Reach midnight.", "coin1", UI.PINK],
	]
	for i in cards.size():
		var card := HelpCard.new()
		card.title = cards[i][0]
		card.text = cards[i][1]
		card.sprite = cards[i][2]
		card.color = cards[i][3]
		card.size = CARD
		card.delay = i * 0.06
		card.position = Vector2((i % 3) * (CARD.x + 20.0), (i / 3) * (CARD.y + 30.0) - 10.0)
		body.add_child(card)


class HelpCard extends Control:
	var title := ""
	var text := ""
	var sprite := ""
	var color := UI.YELLOW
	var delay := 0.0
	var _t := 0.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	func _process(delta: float) -> void:
		delay -= delta
		if delay <= 0.0 and _t < 1.0:
			_t = minf(_t + delta / 0.3, 1.0)
		queue_redraw()

	func _draw() -> void:
		if _t <= 0.0:
			return
		var k := UI.back_out(_t)
		var mid := size * 0.5
		draw_set_transform_matrix(Transform2D(-0.014, Vector2(k, k), 0.0, mid))
		var r := Rect2(-mid, size)
		UI.plate(self, r, UI.INK, color, 0.08)
		var tex := Sprites.get_tex(sprite)
		var by := 8.0 if tex.get_width() <= 12 else 5.0
		var icon := tex.get_size() * by
		var bob := sin(Time.get_ticks_msec() * 0.004 + delay * 30.0) * 4.0
		draw_texture_rect(tex, Rect2(Vector2(r.end.x - icon.x - 22.0, r.position.y + 18.0 + bob), icon), false)
		UI.outlined(self, UI.display_font(), r.position + Vector2(26, 66), title, 42, color)
		UI.paragraph(self, r.position + Vector2(26, 160), text, size.x - 52.0, 36, UI.WHITE)
		draw_set_transform_matrix(Transform2D.IDENTITY)
