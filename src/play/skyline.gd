class_name Skyline
extends RefCounted
## What's behind the floor: the city, as the evening goes by. A sunset going down to a
## starry night, towers in three layers with their windows coming on as people get
## home, a commuter train, the traffic. All in the game's own pixels. The middle of it
## is under the floor: as the walls come in, there's more of it to see.

## Top and bottom of the sky, by how far the evening's got, 0 to 1.
const SKIES := [
	[0.0, Color("3a1f6e"), Color("ff8a3c")],
	[0.25, Color("2a1660"), Color("e0406f")],
	[0.5, Color("170f4a"), Color("8a2f8f")],
	[0.75, Color("090728"), Color("35206e")],
	[1.0, Color("03030f"), Color("1c1040")],
]
const BANDS := 14
const LAYERS := [
	# Parallax, how dark, tallest, width of a block, window step and size.
	{"parallax": 0.2, "dark": 0.5, "height": 170.0, "width": 26, "step": 0, "size": 0},
	{"parallax": 0.5, "dark": 0.72, "height": 140.0, "width": 22, "step": 4, "size": 1},
	{"parallax": 1.0, "dark": 0.93, "height": 104.0, "width": 30, "step": 5, "size": 2},
]
const SPAN := 720
const WINDOW_COLORS := [Color("fbf236"), Color("ffc24a"), Color("eec39a"), Color("5fcde4")]

var _layers: Array = []
var _stars := PackedVector3Array()
var _clouds: Array[Vector3] = []
var _time := 0.0


func _init() -> void:
	# Its own generator: the city's the same however the run's dice fall.
	var rng := RandomNumberGenerator.new()
	rng.seed = 2016
	for def: Dictionary in LAYERS:
		var blocks := []
		var x := float(-SPAN)
		while x < SPAN:
			var w := rng.randi_range(int(def.width) / 2, int(def.width))
			# Lower in the middle, where the floor hides it; tall towers at the sides.
			var side := clampf(absf(x) / 240.0, 0.0, 1.0)
			var h: float = float(def.height) * lerpf(0.3, 1.0, side * side) * rng.randf_range(0.55, 1.0)
			var block := {"x": x, "w": float(w), "h": h, "windows": PackedVector3Array()}
			if int(def.step) > 0:
				var wx := 2.0
				while wx < w - 2.0:
					var wy := 3.0
					while wy < h - 2.0:
						# Its place, and how late it comes on.
						if rng.randf() < 0.75:
							block.windows.append(Vector3(wx, wy, rng.randf()))
						wy += def.step
					wx += def.step
			blocks.append(block)
			x += w + rng.randi_range(0, 2)
		_layers.append({"def": def, "blocks": blocks})
	for i in 150:
		_stars.append(Vector3(rng.randf_range(-SPAN, SPAN), rng.randf_range(0.0, 1.0), rng.randf()))
	for i in 9:
		_clouds.append(Vector3(rng.randf_range(-SPAN, SPAN), rng.randf_range(0.05, 0.6), rng.randf_range(30.0, 90.0)))


func step(dt: float) -> void:
	_time += dt


static func _sky_at(night: float, which: int) -> Color:
	for i in SKIES.size() - 1:
		if night <= SKIES[i + 1][0]:
			var t := inverse_lerp(float(SKIES[i][0]), float(SKIES[i + 1][0]), night)
			return (SKIES[i][which] as Color).lerp(SKIES[i + 1][which], t)
	return SKIES[SKIES.size() - 1][which]


func draw(c: CanvasItem, seen: Rect2, camera: Vector2, floor_rect: Rect2, night: float) -> void:
	var top := _sky_at(night, 1)
	var bottom := _sky_at(night, 2)
	# The sky, in the hard bands of an old sunset.
	var band_h := ceilf(seen.size.y / BANDS)
	for i in BANDS:
		var t := float(i) / (BANDS - 1)
		c.draw_rect(Rect2(seen.position.x, seen.position.y + i * band_h, seen.size.x, band_h + 1.0), top.lerp(bottom, t * t))
	_draw_stars(c, seen, camera, night)
	_draw_sun(c, seen, camera, night)
	_draw_clouds(c, seen, night, bottom)
	var base := seen.end.y
	for layer: Dictionary in _layers:
		_draw_layer(c, layer, seen, camera, base, floor_rect, night, top, bottom)
	_draw_traffic(c, seen, base, night)
	_draw_train(c, seen, base)


func _draw_stars(c: CanvasItem, seen: Rect2, camera: Vector2, night: float) -> void:
	var shown := clampf((night - 0.3) / 0.5, 0.0, 1.0)
	if shown <= 0.0:
		return
	for s in _stars:
		var twinkle := 0.55 + 0.45 * sin(_time * (1.0 + s.z * 3.0) + s.z * 40.0)
		var at := Vector2(s.x + camera.x * 0.9, seen.position.y + s.y * seen.size.y * 0.8)
		if seen.has_point(at):
			c.draw_rect(Rect2(at.round(), Vector2.ONE), Color(1, 1, 1, shown * twinkle))


## The sun goes down on the right; the moon comes up on the left.
func _draw_sun(c: CanvasItem, seen: Rect2, camera: Vector2, night: float) -> void:
	var sun_t := clampf(night / 0.5, 0.0, 1.0)
	if sun_t < 1.0:
		var at := Vector2(seen.get_center().x + 195.0 + camera.x * 0.7, lerpf(seen.position.y + seen.size.y * 0.42, seen.end.y + 20.0, sun_t))
		var radius := 34
		for y in range(-radius, radius + 1):
			# Slats, wider towards the bottom.
			if y > 4 and (y + int(_time * 6.0)) % (10 - y / 8) < 2 + y / 12:
				continue
			var half := sqrt(float(radius * radius - y * y))
			var t := float(y + radius) / (radius * 2.0)
			c.draw_rect(Rect2(at.x - half, at.y + y, half * 2.0, 1.0), Color("fff27a").lerp(Color("ff3f7f"), t))
	var moon_t := clampf((night - 0.45) / 0.45, 0.0, 1.0)
	if moon_t > 0.0:
		var at := Vector2(seen.get_center().x - 200.0 + camera.x * 0.8, lerpf(seen.end.y, seen.position.y + 44.0, moon_t))
		c.draw_circle(at.round(), 15.0, Color("eef0ff"), true, -1.0, false)
		c.draw_circle((at + Vector2(5, -3)).round(), 13.0, _sky_at(night, 1).lerp(_sky_at(night, 2), 0.2), true, -1.0, false)


func _draw_clouds(c: CanvasItem, seen: Rect2, night: float, bottom: Color) -> void:
	var tint := bottom.lerp(Color.WHITE, 0.22 * (1.0 - night))
	tint.a = lerpf(0.7, 0.25, night)
	var width := float(SPAN) * 2.0
	for cloud in _clouds:
		var x := fposmod(cloud.x + _time * (2.0 + cloud.y * 5.0) + SPAN, width) - SPAN
		var y := seen.position.y + cloud.y * seen.size.y
		c.draw_rect(Rect2(Vector2(x, y).round(), Vector2(cloud.z, 2.0)), tint)
		c.draw_rect(Rect2(Vector2(x + cloud.z * 0.2, y + 2.0).round(), Vector2(cloud.z * 0.5, 1.0)), tint)


func _draw_layer(c: CanvasItem, layer: Dictionary, seen: Rect2, camera: Vector2, base: float, floor_rect: Rect2, night: float, top: Color, bottom: Color) -> void:
	var def: Dictionary = layer.def
	var dark: float = def.dark
	var body := bottom.lerp(top, 0.35).lerp(Color("07051a"), dark)
	var lit_share := lerpf(0.12, 0.72, night)
	var off: float = (1.0 - float(def.parallax)) * camera.x
	var size_now := float(def.size)
	var hidden := floor_rect.grow(-size_now - 1.0)
	for block: Dictionary in layer.blocks:
		var x: float = block.x + off
		var w: float = block.w
		var h: float = block.h
		if x + w < seen.position.x or x > seen.end.x:
			continue
		var building := Rect2(x, base - h, w, h)
		if hidden.encloses(building):
			continue
		c.draw_rect(building, body)
		# A lit edge on the sunset's side.
		c.draw_rect(Rect2(x + w - 1.0, base - h, 1.0, h), body.lerp(bottom, 0.3 * (1.0 - night)))
		if size_now <= 0.0:
			continue
		for win: Vector3 in block.windows:
			if win.z > lit_share:
				continue
			var at := Vector2(x + win.x, base - h + win.y)
			if at.y >= seen.end.y or hidden.has_point(at):
				continue
			var color: Color = WINDOW_COLORS[int(win.z * 37.0) % WINDOW_COLORS.size()]
			# A few have a television on.
			if int(win.z * 997.0) % 13 == 0:
				color = Color("9fd8ff").lerp(Color("5f6fff"), 0.5 + 0.5 * sin(_time * (4.0 + win.z * 9.0) + win.x))
			c.draw_rect(Rect2(at, Vector2(size_now, size_now)), Color(color, 0.85 if size_now > 1.0 else 0.55))


## Head and tail lights, each way, along the bottom of the screen.
func _draw_traffic(c: CanvasItem, seen: Rect2, base: float, night: float) -> void:
	var road := base - 4.0
	c.draw_rect(Rect2(seen.position.x, road - 3.0, seen.size.x, 7.0), Color("07051a"))
	var bright := lerpf(0.65, 1.0, night)
	var width := seen.size.x + 40.0
	for i in 16:
		var away := i % 2 == 0
		var speed := 40.0 + float(i * 7 % 23)
		var x := fposmod(float(i) * 83.0 + _time * speed * (1.0 if away else -1.0), width) + seen.position.x - 20.0
		var y := road - 1.0 if away else road + 1.0
		var color := Color("ff3f4f") if away else Color("fff2b0")
		c.draw_rect(Rect2(Vector2(x, y).round(), Vector2(2, 1)), Color(color, bright))


## The 17:42, every so often, on its viaduct.
func _draw_train(c: CanvasItem, seen: Rect2, base: float) -> void:
	var line := base - 15.0
	c.draw_rect(Rect2(seen.position.x, line, seen.size.x, 1.0), Color("07051a"))
	var x := seen.position.x + fposmod(_time * 90.0, seen.size.x + 900.0) - 200.0
	for car in 6:
		var left := x - car * 25.0
		c.draw_rect(Rect2(Vector2(left, line - 7.0).round(), Vector2(23, 7)), Color("10102a"))
		for w in 5:
			c.draw_rect(Rect2(Vector2(left + 2.0 + w * 4.0, line - 5.0).round(), Vector2(2, 2)), Color("ffe27a"))
	c.draw_rect(Rect2(Vector2(x + 23.0, line - 3.0).round(), Vector2(3, 1)), Color.WHITE)
